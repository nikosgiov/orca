package main

import (
	"log"
	"net/http"

	"go_backend/internal/api"
	"go_backend/internal/config"
	"go_backend/internal/services/docker"
	"go_backend/internal/services/notifications"
	"go_backend/internal/services/system"
)

func main() {
	config.LoadConfig()

	// Start system metrics aggregator
	system.GlobalCollector.Start()

	// Initialize Firebase Notifications Admin
	notifications.InitFCM()

	// Initialize Docker Client and start continuous Events streaming
	docker.InitClient()
	docker.GlobalMonitor.Start()

	r := api.SetupRouter()

	log.Printf("Server starting on port %s", config.AppConfig.Port)
	if err := http.ListenAndServe(":"+config.AppConfig.Port, r); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
