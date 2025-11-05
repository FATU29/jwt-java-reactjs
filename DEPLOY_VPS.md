# Hướng dẫn Deploy lên Digital Ocean VPS

## 🚀 Deploy Tự Động (Khuyến nghị)

### Script All-in-one: `scripts/deploy.sh`

Một script duy nhất để làm tất cả:

#### Bước 1: Setup SSH Keys (Lần đầu tiên)

```bash
cd /home/hhg/code/jwt-java-reactjs

# Setup SSH keys (tạo key nếu chưa có và copy lên server)
bash scripts/deploy.sh --setup-ssh
```

Script này sẽ:

- Tạo SSH key nếu chưa có
- Copy public key lên server (bạn sẽ nhập password một lần)
- Kiểm tra passwordless SSH

#### Bước 2: Deploy

**Deploy từ Git (Khuyến nghị):**

```bash
# Deploy từ GitHub (clone/update và deploy tự động)
bash scripts/deploy.sh --git
```

**Deploy từ Local Code:**

```bash
# Deploy từ code local
bash scripts/deploy.sh --local
```

**Auto-detect (tự động phát hiện):**

```bash
# Tự động phát hiện: Git nếu có .git, else local
bash scripts/deploy.sh
```

**Cấu hình tùy chọn:**

```bash
# Thay đổi IP và user
bash scripts/deploy.sh --git --ip 192.168.1.100 --user ubuntu

# Thay đổi repository hoặc branch
bash scripts/deploy.sh --git --repo https://github.com/user/repo.git --branch main

# Sử dụng SSH key cụ thể
bash scripts/deploy.sh --git --ssh-key ~/.ssh/my_key

# Xem tất cả options
bash scripts/deploy.sh --help
```

**Lợi ích:**

- ✅ Một script duy nhất cho tất cả
- ✅ Tự động phát hiện mode
- ✅ Hỗ trợ cả Git và Local deployment
- ✅ Tự động cài đặt Docker, Nginx, Git
- ✅ Setup SSH keys tự động

### Cấu hình tùy chọn:

```bash
# Sử dụng SSH key cụ thể
SSH_KEY=~/.ssh/id_rsa bash scripts/deploy.sh

# Thay đổi user và IP
VPS_USER=ubuntu VPS_IP=167.172.81.150 bash scripts/deploy.sh

# Thay đổi đường dẫn trên server
VPS_PATH=/home/user/jwt-app bash scripts/deploy.sh

# Kết hợp tất cả
VPS_USER=ubuntu VPS_IP=167.172.81.150 SSH_KEY=~/.ssh/my_key bash scripts/deploy.sh

# Hoặc với remote_deploy.sh trực tiếp
VPS_USER=ubuntu VPS_IP=167.172.81.150 SSH_KEY=~/.ssh/my_key bash scripts/remote_deploy.sh
```

Script sẽ tự động:

- ✅ Kiểm tra SSH connection
- ✅ Cài đặt Docker và Docker Compose nếu chưa có
- ✅ Upload code lên server (dùng rsync, bỏ qua node_modules, .git, etc.)
- ✅ Cài đặt Nginx nếu chưa có
- ✅ Chạy deploy script trên server
- ✅ Setup firewall
- ✅ Kiểm tra kết quả

---

## 📋 Deploy Thủ Công

Nếu muốn deploy thủ công hoặc script tự động không hoạt động:

## Bước 1: SSH vào server

```bash
ssh root@167.172.81.150
# hoặc
ssh user@167.172.81.150
```

## Bước 2: Cài đặt Docker và Docker Compose (nếu chưa có)

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose -y
# hoặc
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add user to docker group (nếu không phải root)
usermod -aG docker $USER
```

## Bước 3: Upload code lên server

### Option 1: Clone từ Git

```bash
cd /opt
git clone <your-repo-url> jwt-java-reactjs
cd jwt-java-reactjs
```

### Option 2: Upload qua SCP

```bash
# Từ máy local
scp -r /home/hhg/code/jwt-java-reactjs root@167.172.81.150:/opt/jwt-java-reactjs
```

### Option 3: Upload qua rsync (tốt nhất)

```bash
# Từ máy local
rsync -avz --exclude 'node_modules' --exclude '.git' \
  /home/hhg/code/jwt-java-reactjs/ \
  root@167.172.81.150:/opt/jwt-java-reactjs/
```

## Bước 4: Chạy deploy script

```bash
cd /opt/jwt-java-reactjs
chmod +x scripts/deploy_vps.sh
bash scripts/deploy_vps.sh
```

## Bước 5: Setup Nginx (nếu script không tự động setup)

```bash
# Copy nginx config
sudo cp deploy/nginx/jwt-app.conf /etc/nginx/sites-available/jwt-app

# Create symlink
sudo ln -sf /etc/nginx/sites-available/jwt-app /etc/nginx/sites-enabled/jwt-app

# Remove default nginx config
sudo rm -f /etc/nginx/sites-enabled/default

# Test và reload nginx
sudo nginx -t
sudo systemctl reload nginx
```

## Bước 6: Mở firewall (nếu có)

```bash
# Mở port 80 và 443
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

## Bước 7: Kiểm tra

```bash
# Test frontend
curl http://167.172.81.150

# Test backend API
curl http://167.172.81.150/api/auth/login -X POST

# Xem logs
docker compose -f deploy/compose.vps.yml logs -f
```

## Các lệnh hữu ích

```bash
# Xem status containers
docker compose -f deploy/compose.vps.yml ps

# Xem logs
docker compose -f deploy/compose.vps.yml logs -f [service-name]

# Restart services
docker compose -f deploy/compose.vps.yml restart

# Stop services
docker compose -f deploy/compose.vps.yml down

# Rebuild và restart
docker compose -f deploy/compose.vps.yml up -d --build
```

## Setup SSL với Let's Encrypt (Khuyến nghị)

```bash
# Install certbot
apt install certbot python3-certbot-nginx -y

# Get SSL certificate
certbot --nginx -d 167.172.81.150

# Auto-renewal đã được setup tự động
```

## Troubleshooting

### Container không start

```bash
docker compose -f deploy/compose.vps.yml logs [service-name]
```

### Nginx không chạy

```bash
sudo nginx -t
sudo systemctl status nginx
sudo journalctl -u nginx -f
```

### Port đã được sử dụng

```bash
netstat -tulpn | grep :80
netstat -tulpn | grep :8080
```
