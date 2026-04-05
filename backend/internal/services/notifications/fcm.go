package notifications

import (
	"context"
	"log"

	"go_backend/internal/config"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

var fcmClient *messaging.Client

func InitFCM() {
	if config.AppConfig.FcmServiceAccountFile == "" {
		log.Println("FCM_SERVICE_ACCOUNT_FILE not set, skipping FCM initialization")
		return
	}

	opt := option.WithCredentialsFile(config.AppConfig.FcmServiceAccountFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Printf("FCM Init error: %v", err)
		return
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Printf("Messaging client error: %v", err)
		return
	}

	fcmClient = client
	log.Println("FCM initialized successfully")
}

func SendNotification(token, title, body string) {
	if fcmClient == nil {
		log.Println("FCM client not initialized")
		return
	}

	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Token: token,
	}

	_, err := fcmClient.Send(context.Background(), message)
	if err != nil {
		log.Printf("Error sending notification: %v", err)
	}
}
