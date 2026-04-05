# Stage 1: Build
FROM golang:1.24-alpine AS builder

# Install build dependencies (if any, like gcc for CGO, but CGO is disabled here)
RUN apk add --no-cache git

WORKDIR /app

# Copy dependency files and download
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

RUN go mod tidy

# Build the executable
# CGO_ENABLED=0 creates a statically-linked binary that doesn't depend on GLIBC (perfect for alpine)
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/server/main.go

# Stage 2: Final Image
FROM alpine:latest

WORKDIR /app

# Install CA Certificates and Docker CLI for operations
RUN apk --no-cache add ca-certificates docker-cli docker-cli-compose libc6-compat

# Copy the binary and config
COPY --from=builder /app/main .
COPY --from=builder /app/.env .
COPY dockercontroller-firebase.json firebase.json

# Expose Port
EXPOSE 9800

CMD ["./main"]
