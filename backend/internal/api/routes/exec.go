package routes

import (
	"context"
	"io"
	"log"
	"net/http"

	"go_backend/internal/services/docker"

	"github.com/docker/docker/api/types/container"
	"github.com/go-chi/chi/v5"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func ExecWebSocketHandler(w http.ResponseWriter, r *http.Request) {
	containerID := chi.URLParam(r, "container_id")
	if containerID == "" {
		http.Error(w, "Missing container_id", http.StatusBadRequest)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WS Upgrade Error: %v", err)
		return
	}
	defer conn.Close()

	ctx := context.Background()

	// 1. Create Exec Configuration
	execConfig := container.ExecOptions{
		AttachStdout: true,
		AttachStderr: true,
		AttachStdin:  true,
		Tty:          true,
		Cmd:          []string{"/bin/sh"},
	}

	execCreate, err := docker.Cli.ContainerExecCreate(ctx, containerID, execConfig)
	if err != nil {
		conn.WriteMessage(websocket.TextMessage, []byte("Exec Create failed: "+err.Error()))
		return
	}

	// Attach to Exec Session
	execAttach, err := docker.Cli.ContainerExecAttach(ctx, execCreate.ID, container.ExecStartOptions{Tty: true})
	if err != nil {
		conn.WriteMessage(websocket.TextMessage, []byte("Exec Attach failed: "+err.Error()))
		return
	}
	defer execAttach.Close()

	// Pipe to/from WebSocket and Docker Stream
	// Read from WS -> Write to Docker
	go func() {
		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				execAttach.Close()
				return
			}
			execAttach.Conn.Write(message)
		}
	}()

	// Read from Docker -> Write to WS
	buf := make([]byte, 1024)
	for {
		n, err := execAttach.Reader.Read(buf)
		if err != nil {
			if err != io.EOF {
				log.Printf("Read from Docker failed: %v", err)
			}
			break
		}
		if err := conn.WriteMessage(websocket.TextMessage, buf[:n]); err != nil {
			break
		}
	}
}
