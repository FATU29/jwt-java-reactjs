#!/usr/bin/env bash
set -euo pipefail

# Simple deploy script for a basic VPS with Docker and Nginx installed.
# It builds and starts containers, then prints instructions to enable the Nginx site.

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

echo "==> Building and starting containers (VPS profile)"
docker compose -f deploy/compose.vps.yml up -d --build

echo "\n==> Containers running (bound to localhost only):"
docker compose -f deploy/compose.vps.yml ps

NGINX_CONF_SRC="$ROOT_DIR/deploy/nginx/jwt-app.conf"
NGINX_CONF_DST="/etc/nginx/sites-available/jwt-app.conf"

echo "\n==> Next steps (run with sudo):"
cat <<EOF
sudo cp "$NGINX_CONF_SRC" "$NGINX_CONF_DST"
sudo ln -sf "$NGINX_CONF_DST" /etc/nginx/sites-enabled/jwt-app.conf
sudo nginx -t && sudo systemctl reload nginx

# Optional: Enable firewall rules
# sudo ufw allow 'Nginx Full'

# Check
curl -I http://localhost
EOF

echo "\nDone. Point your domain's DNS (A record) to this server's IP and set server_name in deploy/nginx/jwt-app.conf."
