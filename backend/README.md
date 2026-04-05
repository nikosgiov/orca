# Orca — Backend

The Orca backend is a lightweight Go server that acts as a secure reverse proxy to the Docker daemon. It handles JWT authentication, system metrics collection, Docker event monitoring, push notifications via Firebase Cloud Messaging, and WebSocket-based container shell sessions.

The full stack is composed of:

- **`backend`** — the Go application
- **`nginx`** — an Nginx reverse proxy with optional TLS (HTTP or HTTPS, auto-detected at startup)

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Firebase Service Account Key](#firebase-service-account-key)
- [Deployment](#deployment)
  - [Option A: Docker Compose (recommended)](#option-a-docker-compose-recommended)
  - [Option B: Docker run (manual)](#option-b-docker-run-manual)
  - [Verify](#verify)
- [TLS / HTTPS Setup](#tls--https-setup)
- [Features](#features)

---

## Prerequisites

- **Docker** and **Docker Compose** installed on the host machine
- A **Firebase** project with Cloud Messaging enabled (see [Firebase Setup](../README.md#1-firebase-setup) in the main README)
- Access to the Docker socket on the host (`/var/run/docker.sock`)

---

## Configuration

### Environment Variables

Create a `.env` file in the `backend/` directory before starting the stack:

```env
# Authentication
SECRET_KEY=your_strong_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=300
VALID_USERNAME=your_username
VALID_PASSWORD=your_strong_password_here

# Firebase / FCM
FCM_PROJECT_ID=your_firebase_project_id

# Firebase Client Config (provisioned to the mobile app on login)
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
FIREBASE_PROJECT_ID=your_firebase_project_id

# Docker
DOCKER_SOCKET_PATH=/var/run/docker.sock
COMPOSE_PROJECTS_DIR=/path/to/your/compose/projects

# Nginx ports
HTTP_PORT=9800
HTTPS_PORT=8443

# Go app internal port (must match what Nginx proxies to)
PORT=9800
```

| Variable | Description |
|---|---|
| `SECRET_KEY` | Secret used to sign JWT tokens. Use a long, random string. |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | How long JWT tokens remain valid (in minutes). |
| `VALID_USERNAME` / `VALID_PASSWORD` | Login credentials for the mobile app. |
| `FCM_SERVICE_ACCOUNT_FILE` | Path to the Firebase service account JSON, relative to the working directory. |
| `FCM_PROJECT_ID` | Your Firebase project ID. |
| `FIREBASE_API_KEY` | Firebase API key (from Firebase Console > Project Settings > General). |
| `FIREBASE_APP_ID` | Firebase App ID. |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase Messaging Sender ID. |
| `FIREBASE_STORAGE_BUCKET` | Firebase Storage Bucket. |
| `FIREBASE_PROJECT_ID` | Firebase Project ID. |
| `DOCKER_SOCKET_PATH` | Path to the Docker socket (usually `/var/run/docker.sock`). |
| `COMPOSE_PROJECTS_DIR` | Root directory for Docker Compose projects. Subfolders containing a `docker-compose.yml` are auto-discovered. |
| `HTTP_PORT` | Port Nginx listens on for HTTP traffic (exposed to the app). |
| `HTTPS_PORT` | Port Nginx listens on for HTTPS traffic (exposed to the app). |
| `PORT` | Internal port the Go app listens on (not exposed directly, proxied by Nginx). |

### Firebase Service Account Key

Copy the JSON file downloaded from Firebase Console (Project Settings > Service Accounts > Generate new private key) into the `backend/` directory and name it `dockercontroller-firebase.json`.

```bash
cp /path/to/your-firebase-key.json ./dockercontroller-firebase.json
```

> **Never commit this file to version control.** It is already listed in `.gitignore`.

---

## Deployment

### Option A: Docker Compose (recommended)

The `docker-compose.yml` in this directory spins up both the Go backend and the Nginx proxy together.

```bash
cd orca/backend

# Build and start both services
docker compose up -d --build
```

> **Important:** If you want GPU monitoring (NVIDIA), the `backend` service in `docker-compose.yml` already includes the `deploy.resources.reservations.devices` block. Make sure the NVIDIA Container Toolkit is installed on the host.

To view logs:

```bash
docker compose logs -f
```

To stop and remove containers:

```bash
docker compose down
```

### Option B: Docker run (manual)

If you prefer to run without Docker Compose:

```bash
# Build the image
docker build -t orca-backend .

# Run the container
docker run -d \
  --name orca-backend \
  --restart unless-stopped \
  --gpus all \
  -p 9800:9800 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /path/to/your/compose/projects:/path/to/your/compose/projects \
  --env-file .env \
  orca-backend
```

> **Key flags:**
> - `-v /var/run/docker.sock:/var/run/docker.sock` — gives the backend access to the host Docker engine.
> - Mount your compose projects directory if you want compose auto-discovery.
> - `--gpus all` is required only if you want NVIDIA GPU monitoring.

### Verify

```bash
curl http://localhost:9800/version
# Returns: {"version":"1.0.0"}
```

---

## TLS / HTTPS Setup

The Nginx proxy auto-detects whether TLS is enabled based on the presence of `server.pem` and `server.key` in the `backend/` directory.

To enable HTTPS:
1. Replace the placeholder `server.key` and `server.pem` files in the `backend/` directory with your actual certificate and private key.
2. Ensure the filenames remain `server.key` and `server.pem` for auto-detection.
3. Restart the stack: `docker compose up -d`.

If these files are missing or invalid, Nginx will fallback to serving plain HTTP on `HTTP_PORT`.

---

## Features

| Feature | Description |
|---|---|
| **Docker Socket Proxy** | Reverse-proxies requests directly to the Docker Engine API via Unix socket or TCP, providing full Docker REST API access behind authentication |
| **JWT Authentication** | Username/password login with HS256-signed JWT tokens and configurable expiry |
| **Rate Limiting** | Per-IP rate limiting (100 req/min global, 5 req/min on login) to prevent abuse |
| **System Metrics Collection** | Collects CPU, memory, disk, disk I/O, network I/O, and NVIDIA GPU stats every second using `gopsutil` and `nvidia-smi` |
| **Multi-Tier Aggregation** | 1-second granularity (last 60s), 1-minute averages (last 6h), and 1-hour averages (last 24h) |
| **Docker Event Monitoring** | Continuously listens to the Docker event stream and dispatches push notifications on container state changes |
| **Resource Threshold Alerts** | Monitors CPU and memory against configurable thresholds with a 5-minute cooldown to avoid alert storms |
| **Firebase Cloud Messaging** | Sends push notifications via FCM Admin SDK |
| **Docker Compose Management** | Auto-discovers compose projects from a configurable directory and running container labels; runs compose commands with streamed NDJSON output |
| **WebSocket Exec** | Opens interactive `/bin/sh` sessions inside containers via WebSocket for the mobile terminal |
| **Nginx TLS Proxy** | Nginx reverse proxy with auto-detected HTTP/HTTPS mode based on the presence of certificate files |
| **Dockerized Deployment** | Multi-stage Dockerfile producing a minimal Alpine-based image |
