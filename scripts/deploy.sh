#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# JWT App Deployment Script - All-in-one
# ============================================================================
# This script handles:
# - SSH setup
# - Deploy from Git repository
# - Deploy from local code
# - Server-side deployment with Docker and Nginx
# ============================================================================

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

# ============================================================================
# Configuration
# ============================================================================

# Load config if exists
CONFIG_FILE="$HOME/.jwt_deploy_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Default values
VPS_IP="${VPS_IP:-167.172.81.150}"
VPS_USER="${VPS_USER:-root}"
VPS_PATH="${VPS_PATH:-/opt/jwt-java-reactjs}"
GIT_REPO="${GIT_REPO:-https://github.com/FATU29/jwt-java-reactjs.git}"
GIT_BRANCH="${GIT_BRANCH:-main}"
SSH_KEY="${SSH_KEY:-}"
DEPLOY_MODE="${DEPLOY_MODE:-auto}"  # auto, git, local

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            DEPLOY_MODE="$2"
            shift 2
            ;;
        --git)
            DEPLOY_MODE="git"
            shift
            ;;
        --local)
            DEPLOY_MODE="local"
            shift
            ;;
        --setup-ssh)
            DEPLOY_MODE="setup-ssh"
            shift
            ;;
        --ip)
            VPS_IP="$2"
            shift 2
            ;;
        --user)
            VPS_USER="$2"
            shift 2
            ;;
        --path)
            VPS_PATH="$2"
            shift 2
            ;;
        --repo)
            GIT_REPO="$2"
            shift 2
            ;;
        --branch)
            GIT_BRANCH="$2"
            shift 2
            ;;
        --ssh-key)
            SSH_KEY="$2"
            shift 2
            ;;
        --help|-h)
            cat <<EOF
JWT App Deployment Script - All-in-one

Usage: bash scripts/deploy.sh [OPTIONS]

Options:
  --mode MODE         Deployment mode: auto, git, local (default: auto)
  --git               Deploy from Git repository
  --local             Deploy from local code
  --setup-ssh         Setup SSH keys only
  --ip IP             VPS IP address (default: 167.172.81.150)
  --user USER         SSH user (default: root)
  --path PATH         Deployment path on server (default: /opt/jwt-java-reactjs)
  --repo REPO         Git repository URL
  --branch BRANCH     Git branch (default: main)
  --ssh-key PATH      SSH private key path
  --help, -h          Show this help message

Examples:
  # Auto-detect mode (Git if .git exists, else local)
  bash scripts/deploy.sh

  # Deploy from Git
  bash scripts/deploy.sh --git

  # Deploy from local code
  bash scripts/deploy.sh --local

  # Setup SSH only
  bash scripts/deploy.sh --setup-ssh

  # Custom configuration
  bash scripts/deploy.sh --ip 192.168.1.100 --user ubuntu --git
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Functions
# ============================================================================

# Setup SSH keys
setup_ssh() {
    echo "🔐 Setting up SSH keys for ${VPS_USER}@${VPS_IP}..."
    echo ""

    SSH_KEY_PATH="${SSH_KEY:-$HOME/.ssh/id_rsa}"
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo "==> Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "deploy@$(hostname)" || true
        echo "✅ SSH key generated at $SSH_KEY_PATH"
    else
        echo "✅ SSH key already exists at $SSH_KEY_PATH"
    fi
    echo ""

    echo "==> Your public key:"
    echo "----------------------------------------"
    cat "${SSH_KEY_PATH}.pub" 2>/dev/null || echo "Key not found"
    echo "----------------------------------------"
    echo ""

    read -p "Do you want to copy this key to the server now? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "==> Copying SSH key to server..."
        echo "   (You will be prompted for password once)"
        if ssh-copy-id -i "${SSH_KEY_PATH}.pub" "${VPS_USER}@${VPS_IP}" 2>/dev/null; then
            echo "✅ SSH key copied successfully!"
            echo ""
            echo "==> Testing passwordless SSH..."
            if ssh -o BatchMode=yes -o ConnectTimeout=5 "${VPS_USER}@${VPS_IP}" "echo 'Passwordless SSH works!'" 2>/dev/null; then
                echo "✅ Passwordless SSH is working!"
            else
                echo "⚠️  Passwordless SSH test failed. Please check manually."
            fi
        else
            echo "❌ Failed to copy SSH key. Please do it manually."
            echo "   ssh-copy-id -i ${SSH_KEY_PATH}.pub ${VPS_USER}@${VPS_IP}"
        fi
    fi
    echo ""
}

# Build SSH command
build_ssh_cmd() {
    if [ -z "$SSH_KEY" ]; then
        SSH_KEY="$HOME/.ssh/id_rsa"
    fi
    
    if [ -n "$SSH_KEY" ] && [ -f "$SSH_KEY" ]; then
        SSH_CMD="ssh -i $SSH_KEY"
    else
        SSH_CMD="ssh"
    fi
}

# Test SSH connection
test_ssh() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Testing SSH connection to ${SSH_TARGET}..."
    if ! $SSH_CMD -o ConnectTimeout=5 -o BatchMode=yes "$SSH_TARGET" "echo 'SSH OK'" 2>/dev/null; then
        echo "❌ Cannot connect to ${SSH_TARGET}"
        echo ""
        echo "Please ensure:"
        echo "  1. SSH key is added to server: bash scripts/deploy.sh --setup-ssh"
        echo "  2. Or provide SSH key: --ssh-key /path/to/key"
        echo "  3. Or configure: --ip IP --user USER"
        exit 1
    fi
    echo "✅ SSH connection OK"
    echo ""
}

# Install Docker on server
install_docker() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Checking Docker installation..."
    if ! $SSH_CMD "$SSH_TARGET" "command -v docker >/dev/null 2>&1"; then
        echo "⚠️  Docker not found. Installing..."
        $SSH_CMD "$SSH_TARGET" <<'EOF'
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            rm get-docker.sh
EOF
        echo "✅ Docker installed"
    else
        echo "✅ Docker is installed"
    fi
}

# Install Docker Compose on server
install_docker_compose() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    if ! $SSH_CMD "$SSH_TARGET" "docker compose version >/dev/null 2>&1"; then
        if ! $SSH_CMD "$SSH_TARGET" "command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1"; then
            echo "⚠️  Docker Compose not found. Installing..."
            $SSH_CMD "$SSH_TARGET" <<'EOF'
                apt-get update
                apt-get install -y docker-compose-v2 || apt-get install -y docker-compose || true
EOF
        else
            echo "✅ Docker Compose (standalone) is installed"
        fi
    else
        echo "✅ Docker Compose (plugin) is installed"
    fi
}

# Install Git on server
install_git() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Checking Git installation..."
    if ! $SSH_CMD "$SSH_TARGET" "command -v git >/dev/null 2>&1"; then
        echo "⚠️  Git not found. Installing..."
        $SSH_CMD "$SSH_TARGET" <<'EOF'
            apt-get update
            apt-get install -y git
EOF
        echo "✅ Git installed"
    else
        echo "✅ Git is installed"
    fi
}

# Install Nginx on server
install_nginx() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Checking Nginx installation..."
    if ! $SSH_CMD "$SSH_TARGET" "command -v nginx >/dev/null 2>&1"; then
        echo "⚠️  Nginx not found. Installing..."
        $SSH_CMD "$SSH_TARGET" <<'EOF'
            apt-get update
            apt-get install -y nginx
            systemctl enable nginx
EOF
        echo "✅ Nginx installed"
    else
        echo "✅ Nginx is installed"
    fi
}

# Setup repository from Git
setup_git_repo() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Setting up repository on server..."
    $SSH_CMD "$SSH_TARGET" <<EOF
        if [ -d "${VPS_PATH}/.git" ]; then
            echo "📁 Repository exists. Updating..."
            cd ${VPS_PATH}
            git fetch origin
            git reset --hard origin/${GIT_BRANCH}
            git clean -fd
            echo "✅ Repository updated"
        else
            echo "📁 Cloning repository..."
            rm -rf ${VPS_PATH}
            git clone -b ${GIT_BRANCH} ${GIT_REPO} ${VPS_PATH}
            echo "✅ Repository cloned"
        fi
EOF
}

# Upload local code to server
upload_local_code() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Uploading code to server..."
    echo "   Source: $ROOT_DIR"
    echo "   Target: ${SSH_TARGET}:${VPS_PATH}"
    
    $SSH_CMD "$SSH_TARGET" "mkdir -p ${VPS_PATH}"
    
    if command -v rsync >/dev/null 2>&1; then
        rsync -avz --progress \
            --exclude 'node_modules' \
            --exclude '.git' \
            --exclude 'target' \
            --exclude '.idea' \
            --exclude '*.log' \
            --exclude 'dist' \
            --exclude 'build' \
            --exclude '.env' \
            --exclude '.env.local' \
            "$ROOT_DIR/" \
            "${SSH_TARGET}:${VPS_PATH}/"
        echo "✅ Code uploaded via rsync"
    else
        echo "❌ rsync not found. Please install rsync or use Git deployment."
        exit 1
    fi
}

# Run deployment on server
run_server_deployment() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Running deployment script on server..."
    $SSH_CMD "$SSH_TARGET" <<EOF
        cd ${VPS_PATH}
        
        # Try to use deploy_vps.sh if it exists
        if [ -f "scripts/deploy_vps.sh" ]; then
            chmod +x scripts/deploy_vps.sh
            bash scripts/deploy_vps.sh
        else
            # Fallback: run deployment commands directly
            echo "🚀 Starting deployment to VPS (${VPS_IP})..."
            
            # Create .env files if not exist
            if [ ! -f "jwt-authentication-be/.env" ]; then
                cat > jwt-authentication-be/.env <<ENVEOF
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
ENVEOF
            fi
            
            if [ ! -f "jwt-authentication-fe/.env" ]; then
                echo "VITE_API_BASE_URL=/api" > jwt-authentication-fe/.env
            fi
            
            echo "==> Stopping and removing existing containers..."
            docker compose -f deploy/compose.vps.yml down 2>/dev/null || true
            docker rm -f jwt-postgres jwt-redis jwt-backend jwt-frontend 2>/dev/null || true
            
            echo "==> Building and starting containers..."
            docker compose -f deploy/compose.vps.yml up -d --build
            
            echo "==> Waiting for services to be ready..."
            sleep 10
            
            echo "==> Setting up Nginx..."
            NGINX_CONF_SRC="\$(pwd)/deploy/nginx/jwt-app.conf"
            NGINX_CONF_DST="/etc/nginx/sites-available/jwt-app"
            
            if [ "\$EUID" -eq 0 ]; then
                SUDO=""
            elif sudo -n true 2>/dev/null; then
                SUDO="sudo"
            else
                SUDO=""
            fi
            
            if [ -f "\${NGINX_CONF_SRC}" ]; then
                \$SUDO cp "\${NGINX_CONF_SRC}" "\${NGINX_CONF_DST}"
                \$SUDO ln -sf "\${NGINX_CONF_DST}" /etc/nginx/sites-enabled/jwt-app
                if \$SUDO nginx -t 2>/dev/null; then
                    \$SUDO systemctl reload nginx 2>/dev/null || true
                    echo "✅ Nginx configured"
                fi
            fi
            
            echo "✅ Deployment completed!"
        fi
EOF
}

# Setup firewall
setup_firewall() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Setting up firewall..."
    $SSH_CMD "$SSH_TARGET" <<'EOF'
        if command -v ufw >/dev/null 2>&1; then
            ufw allow 80/tcp 2>/dev/null || true
            ufw allow 443/tcp 2>/dev/null || true
            ufw --force enable 2>/dev/null || true
            echo "✅ Firewall configured"
        else
            echo "⚠️  UFW not installed. Firewall rules may need manual setup."
        fi
EOF
}

# Verify deployment
verify_deployment() {
    build_ssh_cmd
    SSH_TARGET="${VPS_USER}@${VPS_IP}"
    
    echo "==> Verifying deployment..."
    sleep 5
    
    echo "Testing frontend..."
    if $SSH_CMD "$SSH_TARGET" "curl -s -o /dev/null -w '%{http_code}' http://localhost" 2>/dev/null | grep -qE "200|301|302"; then
        echo "✅ Frontend is accessible"
    else
        echo "⚠️  Frontend might not be ready yet"
    fi
    
    echo "Testing backend API..."
    if $SSH_CMD "$SSH_TARGET" "curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost/api/auth/login" 2>/dev/null | grep -qE "200|400|405"; then
        echo "✅ Backend API is accessible"
    else
        echo "⚠️  Backend API might not be ready yet"
    fi
}

# ============================================================================
# Main Deployment Flow
# ============================================================================

main() {
    echo "🚀 JWT App Deployment Script - All-in-one"
    echo "=========================================="
    echo ""
    
    # Handle SSH setup only
    if [ "$DEPLOY_MODE" = "setup-ssh" ]; then
        setup_ssh
        exit 0
    fi
    
    # Auto-detect mode
    if [ "$DEPLOY_MODE" = "auto" ]; then
        if [ -d "$ROOT_DIR/.git" ]; then
            DEPLOY_MODE="git"
            echo "📁 Detected Git repository. Using Git deployment mode."
        else
            DEPLOY_MODE="local"
            echo "📁 No Git repository detected. Using local deployment mode."
        fi
        echo ""
    fi
    
    # Setup SSH key if needed
    if [ -z "$SSH_KEY" ]; then
        SSH_KEY="$HOME/.ssh/id_rsa"
    fi
    
    if [ ! -f "$SSH_KEY" ]; then
        echo "⚠️  SSH key not found at $SSH_KEY"
        echo ""
        read -p "Do you want to setup SSH keys now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_ssh
        else
            echo "Please setup SSH keys first: bash scripts/deploy.sh --setup-ssh"
            exit 1
        fi
    fi
    
    # Test SSH connection
    test_ssh
    
    # Show configuration
    echo "📋 Deployment Configuration:"
    echo "   Mode: ${DEPLOY_MODE}"
    echo "   Server: ${VPS_USER}@${VPS_IP}"
    echo "   Path: ${VPS_PATH}"
    if [ "$DEPLOY_MODE" = "git" ]; then
        echo "   Repository: ${GIT_REPO}"
        echo "   Branch: ${GIT_BRANCH}"
    fi
    echo "   SSH Key: ${SSH_KEY}"
    echo ""
    
    # Ask for confirmation
    read -p "Continue with deployment? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
    
    echo ""
    echo "🚀 Starting deployment..."
    echo ""
    
    # Install prerequisites
    install_docker
    install_docker_compose
    if [ "$DEPLOY_MODE" = "git" ]; then
        install_git
    fi
    install_nginx
    echo ""
    
    # Setup code
    if [ "$DEPLOY_MODE" = "git" ]; then
        setup_git_repo
    else
        upload_local_code
    fi
    echo ""
    
    # Run deployment
    run_server_deployment
    echo ""
    
    # Setup firewall
    setup_firewall
    echo ""
    
    # Verify
    verify_deployment
    echo ""
    
    echo "✅ Deployment completed!"
    echo ""
    echo "📋 Access your application:"
    echo "   Frontend: http://${VPS_IP}"
    echo "   Backend API: http://${VPS_IP}/api"
    echo ""
    echo "📋 Useful commands:"
    echo "   SSH: ssh ${VPS_USER}@${VPS_IP}"
    echo "   View logs: ssh ${VPS_USER}@${VPS_IP} 'cd ${VPS_PATH} && docker compose -f deploy/compose.vps.yml logs -f'"
    echo "   Restart: ssh ${VPS_USER}@${VPS_IP} 'cd ${VPS_PATH} && docker compose -f deploy/compose.vps.yml restart'"
    echo "   Update: bash scripts/deploy.sh${DEPLOY_MODE:+ --$DEPLOY_MODE}"
    echo ""
}

# Run main function
main
