package docker

import (
	"context"
	"log"
	"sync"
	"time"

	"go_backend/internal/services/notifications"

	"github.com/docker/docker/api/types/events"
)

type DockerMonitor struct {
	mu               sync.RWMutex
	registeredTokens []string
}

var GlobalMonitor = &DockerMonitor{
	registeredTokens: []string{},
}

func (dm *DockerMonitor) RegisterToken(token string) {
	dm.mu.Lock()
	defer dm.mu.Unlock()
	for _, t := range dm.registeredTokens {
		if t == token {
			return
		}
	}
	dm.registeredTokens = append(dm.registeredTokens, token)
	log.Printf("Registered token: %s...", token[:10])
}

func (dm *DockerMonitor) UnregisterToken(token string) {
	dm.mu.Lock()
	defer dm.mu.Unlock()
	var updated []string
	for _, t := range dm.registeredTokens {
		if t != token {
			updated = append(updated, t)
		}
	}
	dm.registeredTokens = updated
	log.Printf("Unregistered token: %s...", token[:10])
}

func (dm *DockerMonitor) Start() {
	ctx := context.Background()

	go func() {
		for {
			msgs, errs := Cli.Events(ctx, events.ListOptions{})
			
		InnerLoop:
			for {
				select {
				case msg := <-msgs:
					dm.handleEvent(msg)
				case err := <-errs:
					log.Printf("Docker Events Error: %v", err)
					break InnerLoop
				}
			}
			time.Sleep(5 * time.Second)
		}
	}()
	log.Println("Docker Events Monitoring Listening in background...")
}

func (dm *DockerMonitor) handleEvent(msg events.Message) {
	actorID := msg.Actor.ID
	if len(actorID) > 12 {
		actorID = actorID[:12]
	}
	log.Printf("Docker Event: %s %s (Actor=%s)", msg.Type, msg.Action, actorID)

	if msg.Type == "container" {
		name := msg.Actor.Attributes["name"]
		switch msg.Action {
		case "die", "stop":
			dm.broadcastNotification("Container Alert", "Container "+name+" is down!")
		case "create", "start":
			dm.broadcastNotification("Container Alert", "Container "+name+" is up!")
		}
	}
}

func (dm *DockerMonitor) broadcastNotification(title, body string) {
	dm.mu.RLock()
	tokens := dm.registeredTokens
	dm.mu.RUnlock()

	for _, token := range tokens {
		notifications.SendNotification(token, title, body)
	}
}
