#!/usr/bin/env bash
set -euo pipefail

# Deploy script for VPS with Docker and Nginx
# IP: 167.172.81.150

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

VPS_IP="167.172.81.150"
NGINX_CONF_SRC="$ROOT_DIR/deploy/nginx/jwt-app.conf"
NGINX_CONF_DST="/etc/nginx/sites-available/jwt-app"

echo "🚀 Starting deployment to VPS ($VPS_IP)..."

# Check if .env files exist
if [ ! -f "jwt-authentication-be/.env" ]; then
    echo "⚠️  Warning: jwt-authentication-be/.env not found. Creating default..."
    cat > jwt-authentication-be/.env <<EOF
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/jwt_auth
SPRING_DATASOURCE_USERNAME=jwt_user
SPRING_DATASOURCE_PASSWORD=jwt_password
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_JPA_SHOW_SQL=false
SERVER_PORT=8080
SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver
JWT_SECRET=mySecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLongForSecurity
JWT_ACCESS_TOKEN_EXPIRATION=900000
JWT_REFRESH_TOKEN_EXPIRATION=604800000
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
EOF
    echo "✅ Created jwt-authentication-be/.env"
fi

if [ ! -f "jwt-authentication-fe/.env" ]; then
    echo "⚠️  Warning: jwt-authentication-fe/.env not found. Creating default..."
    echo "VITE_API_BASE_URL=/api" > jwt-authentication-fe/.env
    echo "✅ Created jwt-authentication-fe/.env"
fi

echo ""
echo "==> Stopping and removing existing containers (if any)..."
docker compose -f deploy/compose.vps.yml down 2>/dev/null || true

# Remove containers with same names if they exist (from other compose files)
docker rm -f jwt-postgres jwt-redis jwt-backend jwt-frontend 2>/dev/null || true

echo ""
echo "==> Building and starting containers..."
docker compose -f deploy/compose.vps.yml up -d --build

echo ""
echo "==> Waiting for services to be ready..."
sleep 10

echo ""
echo "==> Containers status:"
docker compose -f deploy/compose.vps.yml ps

echo ""
echo "==> Setting up Nginx..."

# Check if running as root or with sudo (no password)
if [ "$EUID" -eq 0 ]; then
    SUDO=""
    SUDO_AVAILABLE=true
elif sudo -n true 2>/dev/null; then
    SUDO="sudo"
    SUDO_AVAILABLE=true
else
    SUDO_AVAILABLE=false
fi

if [ "$SUDO_AVAILABLE" = true ]; then
    # Copy nginx config
    $SUDO cp "$NGINX_CONF_SRC" "$NGINX_CONF_DST"
    
    # Create symlink
    $SUDO ln -sf "$NGINX_CONF_DST" /etc/nginx/sites-enabled/jwt-app
    
    # Test nginx config
    if $SUDO nginx -t; then
        echo "✅ Nginx config is valid"
        $SUDO systemctl reload nginx
        echo "✅ Nginx reloaded"
    else
        echo "❌ Nginx config test failed!"
        exit 1
    fi
else
    echo "⚠️  Sudo not available. Please run these commands manually:"
    echo ""
    echo "sudo cp \"$NGINX_CONF_SRC\" \"$NGINX_CONF_DST\""
    echo "sudo ln -sf \"$NGINX_CONF_DST\" /etc/nginx/sites-enabled/jwt-app"
    echo "sudo nginx -t && sudo systemctl reload nginx"
    echo ""
fi

echo ""
echo "==> Testing deployment..."
sleep 3

if curl -I -s http://localhost | head -1 | grep -q "200\|301\|302"; then
    echo "✅ Frontend is accessible"
else
    echo "⚠️  Frontend might not be ready yet. Check logs: docker compose -f deploy/compose.vps.yml logs frontend"
fi

if curl -I -s http://localhost/api/auth/login -X POST | head -1 | grep -q "200\|400\|405"; then
    echo "✅ Backend API is accessible"
else
    echo "⚠️  Backend API might not be ready yet. Check logs: docker compose -f deploy/compose.vps.yml logs backend"
fi

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📋 Access your application:"
echo "   Frontend: http://$VPS_IP"
echo "   Backend API: http://$VPS_IP/api"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker compose -f deploy/compose.vps.yml logs -f"
echo "   Restart: docker compose -f deploy/compose.vps.yml restart"
echo "   Stop: docker compose -f deploy/compose.vps.yml down"
echo ""
