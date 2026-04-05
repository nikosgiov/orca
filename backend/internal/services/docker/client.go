package docker

import (
	"log"

	"github.com/docker/docker/client"
)

var Cli *client.Client

func InitClient() {
	var err error
	Cli, err = client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		log.Fatalf("Failed to create Docker client: %v", err)
	}
	log.Println("Docker Client Initialized")
}
