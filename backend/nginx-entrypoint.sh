#!/bin/sh

# Check if SSL certificates are provided and NOT empty
if [ -s /etc/nginx/ssl/server.pem ] && [ -s /etc/nginx/ssl/server.key ]; then
    echo "SSL certificates found, enabling HTTPS..."
    cat <<EOF > /etc/nginx/conf.d/ssl.conf
server {
    listen ${HTTPS_PORT} ssl;

    ssl_certificate /etc/nginx/ssl/server.pem;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # Basic SSL optimization
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
else
    echo "SSL certificates not found or empty, HTTPS disabled."
    rm -f /etc/nginx/conf.d/ssl.conf
fi

# Process the main nginx.conf.template
envsubst '${PORT} ${HTTP_PORT} ${HTTPS_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx
exec nginx -g 'daemon off;'
