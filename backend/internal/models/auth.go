package models

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type TokenResponse struct {
	Token          string                 `json:"token"`
	FirebaseConfig map[string]interface{} `json:"firebaseConfig,omitempty"`
}

