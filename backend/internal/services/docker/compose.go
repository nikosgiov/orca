package docker

import (
	"context"
	"os"
	"path/filepath"
	"strings"

	"github.com/docker/docker/api/types/container"
)

type ContainerInfo struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Image   string `json:"image"`
	State   string `json:"state"`
	Status  string `json:"status"`
	Service string `json:"service"`
}

type ComposeProject struct {
	Name        string          `json:"name"`
	WorkingDir  string          `json:"working_dir"`
	ConfigFiles []string        `json:"config_files"`
	Containers  []ContainerInfo `json:"containers"`
}

func ListComposeProjects() ([]ComposeProject, error) {
	ctx := context.Background()
	containers, err := Cli.ContainerList(ctx, container.ListOptions{All: true})
	if err != nil {
		return nil, err
	}

	projectsMap := make(map[string]*ComposeProject)

	// Auto-discover projects from mounted directory
	projectsDir := os.Getenv("COMPOSE_PROJECTS_DIR")
	if projectsDir != "" {
		if dirs, err := os.ReadDir(projectsDir); err == nil {
			for _, d := range dirs {
				if d.IsDir() {
					dirPath := filepath.Join(projectsDir, d.Name())
					yml := filepath.Join(dirPath, "docker-compose.yml")
					yaml := filepath.Join(dirPath, "docker-compose.yaml")

					var configFiles []string
					if _, err := os.Stat(yml); err == nil {
						configFiles = []string{"docker-compose.yml"}
					} else if _, err := os.Stat(yaml); err == nil {
						configFiles = []string{"docker-compose.yaml"}
					}

					if len(configFiles) > 0 {
						projectsMap[d.Name()] = &ComposeProject{
							Name:        d.Name(),
							WorkingDir:  dirPath,
							ConfigFiles: configFiles,
							Containers:  []ContainerInfo{},
						}
					}
				}
			}
		}
	}

	for _, c := range containers {
		project := c.Labels["com.docker.compose.project"]
		if project == "" {
			continue
		}

		workingDir := c.Labels["com.docker.compose.project.working_dir"]
		configFilesRaw := c.Labels["com.docker.compose.project.config_files"]
		configFiles := strings.Split(configFilesRaw, ",")

		if _, exists := projectsMap[project]; !exists {
			projectsMap[project] = &ComposeProject{
				Name:        project,
				WorkingDir:  workingDir,
				ConfigFiles: configFiles,
				Containers:  []ContainerInfo{},
			}
		}

		name := "unknown"
		if len(c.Names) > 0 {
			name = strings.TrimPrefix(c.Names[0], "/")
		}

		service := c.Labels["com.docker.compose.service"]

		projectsMap[project].Containers = append(projectsMap[project].Containers, ContainerInfo{
			ID:      c.ID[:12],
			Name:    name,
			Image:   c.Image,
			State:   c.State,
			Status:  c.Status,
			Service: service,
		})
	}

	res := []ComposeProject{}
	for _, p := range projectsMap {
		res = append(res, *p)
	}

	return res, nil
}
