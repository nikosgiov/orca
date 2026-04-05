package api

import (
	"encoding/json"
	"net/http"

	mw "go_backend/internal/api/middleware"
	"go_backend/internal/api/routes"
	"go_backend/internal/config"


	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func CorsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func SetupRouter() *chi.Mux {
	r := chi.NewRouter()

	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(CorsMiddleware)

	globalRateLimiter := mw.NewRateLimiter(100, 60)
	r.Use(globalRateLimiter.Middleware)

	loginRateLimiter := mw.NewRateLimiter(5, 60)
	r.With(loginRateLimiter.Middleware).Post("/login", routes.LoginHandler)

	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"version": "1.0.0"})
	})
	
	r.Group(func(r chi.Router) {
		r.Use(mw.AuthMiddleware)

		r.Get("/config/firebase", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(map[string]interface{}{
				"apiKey":            config.AppConfig.FirebaseApiKey,
				"appId":             config.AppConfig.FirebaseAppId,
				"messagingSenderId": config.AppConfig.FirebaseMessagingSenderId,
				"projectId":         config.AppConfig.FirebaseProjectId,
				"storageBucket":     config.AppConfig.FirebaseStorageBucket,
			})
		})

		r.HandleFunc("/*", routes.DockerProxyHandler)
		r.Get("/system/metrics", routes.SystemMetricsHandler)
		r.Get("/compose/projects", routes.ListComposeProjectsHandler)
		r.Post("/compose/command", routes.RunComposeCommandHandler)
		r.HandleFunc("/exec/{container_id}", routes.ExecWebSocketHandler)
		r.Post("/register", routes.RegisterNotificationsHandler)
		r.Post("/unregister", routes.UnregisterNotificationsHandler)
	})

	return r
}
