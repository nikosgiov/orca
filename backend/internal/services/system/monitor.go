package system

import (
	"sync"
	"time"

	"go_backend/internal/services/notifications"
)

type Thresholds struct {
	CPU    float64 `json:"cpu"`
	Memory float64 `json:"memory"`
}

type ResourceMonitor struct {
	mu               sync.RWMutex
	thresholds       Thresholds
	registeredTokens []string
	lastCPUAlert     time.Time
	lastMemoryAlert  time.Time
	cooldown         time.Duration
}

var GlobalResourceMonitor = &ResourceMonitor{
	thresholds: Thresholds{CPU: 80.0, Memory: 85.0},
	cooldown:   5 * time.Minute,
}

func (rm *ResourceMonitor) RegisterToken(token string) {
	rm.mu.Lock()
	defer rm.mu.Unlock()
	for _, t := range rm.registeredTokens {
		if t == token {
			return
		}
	}
	rm.registeredTokens = append(rm.registeredTokens, token)
}

func (rm *ResourceMonitor) UnregisterToken(token string) {
	rm.mu.Lock()
	defer rm.mu.Unlock()
	var updated []string
	for _, t := range rm.registeredTokens {
		if t != token {
			updated = append(updated, t)
		}
	}
	rm.registeredTokens = updated
}

func (rm *ResourceMonitor) SetThresholds(cpu, mem float64) {
	rm.mu.Lock()
	defer rm.mu.Unlock()
	rm.thresholds.CPU = cpu
	rm.thresholds.Memory = mem
}

func (rm *ResourceMonitor) GetThresholds() Thresholds {
	rm.mu.RLock()
	defer rm.mu.RUnlock()
	return rm.thresholds
}

func (rm *ResourceMonitor) CheckAndAlert(point MetricsPoint) {
	rm.mu.RLock()
	thresholds := rm.thresholds
	tokens := rm.registeredTokens
	rm.mu.RUnlock()

	if len(tokens) == 0 {
		return
	}

	now := time.Now()

	if point.CPU > thresholds.CPU {
		if now.Sub(rm.lastCPUAlert) > rm.cooldown {
			rm.broadcastNotification("High CPU Usage", "CPU usage is above threshold!")
			rm.lastCPUAlert = now
		}
	}

	if point.Mem > thresholds.Memory {
		if now.Sub(rm.lastMemoryAlert) > rm.cooldown {
			rm.broadcastNotification("High Memory Usage", "Memory usage is above threshold!")
			rm.lastMemoryAlert = now
		}
	}
}

func (rm *ResourceMonitor) broadcastNotification(title, body string) {
	rm.mu.RLock()
	tokens := rm.registeredTokens
	rm.mu.RUnlock()

	for _, token := range tokens {
		notifications.SendNotification(token, title, body)
	}
}
