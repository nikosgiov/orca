package routes

import (
	"context"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"

	"go_backend/internal/config"
)

func DockerProxyHandler(w http.ResponseWriter, r *http.Request) {
	dockerHost := os.Getenv("DOCKER_HOST")
	var proxy *httputil.ReverseProxy

	if strings.HasPrefix(dockerHost, "tcp://") {
		targetUrl := strings.Replace(dockerHost, "tcp://", "http://", 1)
		target, _ := url.Parse(targetUrl)
		proxy = httputil.NewSingleHostReverseProxy(target)
	} else {
		dialer := &net.Dialer{}
		transport := &http.Transport{
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				return dialer.DialContext(ctx, "unix", config.AppConfig.DockerSocketPath)
			},
		}

		target, _ := url.Parse("http://localhost")
		proxy = httputil.NewSingleHostReverseProxy(target)
		proxy.Transport = transport
	}

	path := r.URL.Path
	if strings.HasPrefix(path, "/docker") {
		r.URL.Path = strings.TrimPrefix(path, "/docker")
	}

	r.Host = "localhost"
	r.URL.Host = "localhost"
	r.URL.Scheme = "http"

	proxy.ServeHTTP(w, r)
}
