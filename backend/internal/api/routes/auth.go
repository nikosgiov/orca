package routes

import (
	"encoding/json"
	"net/http"
	"time"

	"go_backend/internal/config"
	"go_backend/internal/models"

	"github.com/golang-jwt/jwt/v5"
)

func LoginHandler(w http.ResponseWriter, r *http.Request) {
	var req models.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.Username != config.AppConfig.ValidUsername || req.Password != config.AppConfig.ValidPassword {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Create JWT token
	expirationTime := time.Now().Add(time.Duration(config.AppConfig.AccessTokenExpireMinutes) * time.Minute)
	claims := &jwt.MapClaims{
		"sub": req.Username,
		"exp": expirationTime.Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(config.AppConfig.SecretKey))
	if err != nil {
		http.Error(w, "Could not create token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(models.TokenResponse{
		Token: tokenString,
		FirebaseConfig: map[string]interface{}{
			"apiKey":            config.AppConfig.FirebaseApiKey,
			"appId":             config.AppConfig.FirebaseAppId,
			"messagingSenderId": config.AppConfig.FirebaseMessagingSenderId,
			"projectId":         config.AppConfig.FirebaseProjectId,
			"storageBucket":     config.AppConfig.FirebaseStorageBucket,

		},
	})
}


