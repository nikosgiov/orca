package routes

import (
	"encoding/json"
	"net/http"

	"go_backend/internal/services/docker"
	"go_backend/internal/services/system"
)

type NotificationRegistration struct {
	Token                    string `json:"token"`
	EnableDockerMonitoring   bool   `json:"enable_docker_monitoring"`
	EnableResourceMonitoring bool   `json:"enable_resource_monitoring"`
}

type NotificationUnregistration struct {
	Token string `json:"token"`
}

func RegisterNotificationsHandler(w http.ResponseWriter, r *http.Request) {
	var req NotificationRegistration
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.Token == "" {
		http.Error(w, "Device token required", http.StatusBadRequest)
		return
	}

	if req.EnableDockerMonitoring {
		docker.GlobalMonitor.RegisterToken(req.Token)
	} else {
		docker.GlobalMonitor.UnregisterToken(req.Token)
	}

	if req.EnableResourceMonitoring {
		system.GlobalResourceMonitor.RegisterToken(req.Token)
	} else {
		system.GlobalResourceMonitor.UnregisterToken(req.Token)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":             "Successfully registered for notifications",
		"docker_monitoring":   req.EnableDockerMonitoring,
		"resource_monitoring": req.EnableResourceMonitoring,
	})
}

func UnregisterNotificationsHandler(w http.ResponseWriter, r *http.Request) {
	var req NotificationUnregistration
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.Token == "" {
		http.Error(w, "Device token required", http.StatusBadRequest)
		return
	}

	docker.GlobalMonitor.UnregisterToken(req.Token)
	system.GlobalResourceMonitor.UnregisterToken(req.Token)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Successfully unregistered from notifications",
	})
}
