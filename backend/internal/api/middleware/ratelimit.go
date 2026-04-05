package middleware

import (
	"net"
	"net/http"
	"sync"
	"time"
)

type RateLimiter struct {
	requests int
	seconds  int
	mu       sync.Mutex
	store    map[string][]time.Time
}

func NewRateLimiter(requests, seconds int) *RateLimiter {
	return &RateLimiter{
		requests: requests,
		seconds:  seconds,
		store:    make(map[string][]time.Time),
	}
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip, _, err := net.SplitHostPort(r.RemoteAddr)
		if err != nil {
			ip = r.RemoteAddr
		}

		now := time.Now()

		rl.mu.Lock()
		defer rl.mu.Unlock()

		if _, exists := rl.store[ip]; !exists {
			rl.store[ip] = []time.Time{}
		}

		// Clean up old timestamps
		var valid []time.Time
		for _, t := range rl.store[ip] {
			if now.Sub(t) < time.Duration(rl.seconds)*time.Second {
				valid = append(valid, t)
			}
		}
		rl.store[ip] = valid

		if len(rl.store[ip]) >= rl.requests {
			http.Error(w, "Too many requests", http.StatusTooManyRequests)
			return
		}

		rl.store[ip] = append(rl.store[ip], now)
		next.ServeHTTP(w, r)
	})
}
