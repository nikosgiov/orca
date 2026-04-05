package routes

import (
	"encoding/json"
	"net/http"

	"go_backend/internal/models"
	"go_backend/internal/services/system"
)

func SystemMetricsHandler(w http.ResponseWriter, r *http.Request) {
	window := r.URL.Query().Get("window")
	if window == "" {
		window = "30m"
	}

	static := system.GetStaticInfo()
	metrics := system.GlobalCollector.GetAggregatedMetrics(window)

	resp := models.SystemMetricsResponse{
		Static:  static,
		Metrics: metrics,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
