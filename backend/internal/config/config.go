package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	SecretKey                 string
	AccessTokenExpireMinutes  int
	ValidUsername             string
	ValidPassword             string
	FcmServiceAccountFile     string
	FcmProjectId              string
	DockerSocketPath          string
	Port                      string
	FirebaseApiKey            string
	FirebaseAppId             string
	FirebaseMessagingSenderId string
	FirebaseStorageBucket     string
	FirebaseProjectId         string
}

var AppConfig Config

func LoadConfig() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, reading from environment variables")
	}

	AppConfig = Config{
		SecretKey:                 getEnv("SECRET_KEY", "default_secret_key"),
		AccessTokenExpireMinutes:  getEnvInt("ACCESS_TOKEN_EXPIRE_MINUTES", 30),
		ValidUsername:             getEnv("VALID_USERNAME", "admin"),
		ValidPassword:             getEnv("VALID_PASSWORD", "admin"),
		FcmServiceAccountFile:     getEnv("FCM_SERVICE_ACCOUNT_FILE", "firebase.json"),
		FcmProjectId:              getEnv("FCM_PROJECT_ID", ""),
		DockerSocketPath:          getEnv("DOCKER_SOCKET_PATH", "/var/run/docker.sock"),
		Port:                      getEnv("PORT", "8000"),
		FirebaseApiKey:            getEnv("FIREBASE_API_KEY", ""),
		FirebaseAppId:             getEnv("FIREBASE_APP_ID", ""),
		FirebaseMessagingSenderId: getEnv("FIREBASE_MESSAGING_SENDER_ID", ""),
		FirebaseStorageBucket:     getEnv("FIREBASE_STORAGE_BUCKET", ""),
		FirebaseProjectId:         getEnv("FIREBASE_PROJECT_ID", ""),
	}

}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	valueStr := getEnv(key, "")
	if valueStr == "" {
		return fallback
	}
	value, err := strconv.Atoi(valueStr)
	if err != nil {
		return fallback
	}
	return value
}
