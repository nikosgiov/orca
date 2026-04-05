package routes

import (
	"bufio"
	"encoding/json"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"go_backend/internal/services/docker"
)

type ComposeCommandRequest struct {
	Project    string `json:"project"`
	WorkingDir string `json:"working_dir"`
	Command    string `json:"command"` // "up", "down", "logs", etc.
	Service    string `json:"service,omitempty"`
}

type StreamItem struct {
	Type     string `json:"type"` // "stdout", "stderr", "done", "error"
	Data     string `json:"data,omitempty"`
	ExitCode *int   `json:"exit_code,omitempty"`
}

func ListComposeProjectsHandler(w http.ResponseWriter, r *http.Request) {
	projects, err := docker.ListComposeProjects()
	if err != nil {
		http.Error(w, "Docker API error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(projects)
}

func RunComposeCommandHandler(w http.ResponseWriter, r *http.Request) {
	var req ComposeCommandRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.Project == "" && req.WorkingDir == "" {
		http.Error(w, "Either Project or WorkingDir is required", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/x-ndjson")
	w.Header().Set("Transfer-Encoding", "chunked")
	w.WriteHeader(http.StatusOK)

	flusher, ok := w.(http.Flusher)

	cmdParts := []string{"compose"}
	if req.WorkingDir != "" {
		if _, err := os.Stat(req.WorkingDir); err == nil {
			cmdParts = append(cmdParts, "-f", filepath.Join(req.WorkingDir, "docker-compose.yml"))
		} else {
			cmdParts = append(cmdParts, "-p", req.Project)
		}
	} else {
		cmdParts = append(cmdParts, "-p", req.Project)
	}

	cmdParts = append(cmdParts, strings.Fields(req.Command)...)
	if req.Service != "" {
		cmdParts = append(cmdParts, req.Service)
	}

	cmd := exec.Command("docker", cmdParts...)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		writeError(w, err.Error(), flusher)
		return
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		writeError(w, err.Error(), flusher)
		return
	}

	if err := cmd.Start(); err != nil {
		writeError(w, err.Error(), flusher)
		return
	}

	var wg sync.WaitGroup
	wg.Add(2)
	writeChan := make(chan StreamItem, 100)

	go func() {
		defer wg.Done()
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			writeChan <- StreamItem{Type: "stdout", Data: scanner.Text()}
		}
	}()

	go func() {
		defer wg.Done()
		scanner := bufio.NewScanner(stderr)
		for scanner.Scan() {
			writeChan <- StreamItem{Type: "stderr", Data: scanner.Text()}
		}
	}()

	go func() {
		wg.Wait()
		close(writeChan)
	}()

	for item := range writeChan {
		json.NewEncoder(w).Encode(item)
		if ok {
			flusher.Flush()
		}
	}

	exitCode := 0
	if err := cmd.Wait(); err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			exitCode = 1
		}
	}

	json.NewEncoder(w).Encode(StreamItem{Type: "done", ExitCode: &exitCode})
	if ok {
		flusher.Flush()
	}
}

func writeError(w io.Writer, msg string, flusher http.Flusher) {
	json.NewEncoder(w).Encode(StreamItem{Type: "error", Data: msg})
	if flusher != nil {
		flusher.Flush()
	}
}

