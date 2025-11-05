# 🚀 Quick Deploy Guide

Hướng dẫn nhanh để deploy lên Digital Ocean VPS.

## Một Script Cho Tất Cả: `scripts/deploy.sh`

### Bước 1: Setup SSH (Lần đầu tiên)

```bash
cd /home/hhg/code/jwt-java-reactjs
bash scripts/deploy.sh --setup-ssh
```

Bạn sẽ được yêu cầu nhập password SSH một lần để copy public key lên server.

### Bước 2: Deploy

**Deploy từ Git (Khuyến nghị):**

```bash
bash scripts/deploy.sh --git
```

**Deploy từ Local Code:**

```bash
bash scripts/deploy.sh --local
```

**Auto-detect:**

```bash
bash scripts/deploy.sh
```

Script sẽ tự động:
- ✅ Kiểm tra SSH connection
- ✅ Cài đặt Docker/Nginx/Git nếu cần
- ✅ Clone/update từ Git HOẶC upload code local
- ✅ Build và start containers
- ✅ Setup Nginx
- ✅ Mở firewall
- ✅ Kiểm tra kết quả

Script sẽ tự động:
- ✅ Kiểm tra SSH connection
- ✅ Upload code lên server
- ✅ Cài đặt Docker/Nginx nếu cần
- ✅ Build và start containers
- ✅ Setup Nginx config
- ✅ Mở firewall
- ✅ Kiểm tra kết quả

## Truy cập ứng dụng

Sau khi deploy thành công:
- **Frontend**: http://167.172.81.150
- **Backend API**: http://167.172.81.150/api

## Các lệnh hữu ích

```bash
# Xem logs trên server
ssh root@167.172.81.150 'cd /opt/jwt-java-reactjs && docker compose -f deploy/compose.vps.yml logs -f'

# Restart services
ssh root@167.172.81.150 'cd /opt/jwt-java-reactjs && docker compose -f deploy/compose.vps.yml restart'

# Stop services
ssh root@167.172.81.150 'cd /opt/jwt-java-reactjs && docker compose -f deploy/compose.vps.yml down'

# Re-deploy (upload code mới và rebuild)
bash scripts/deploy.sh
```

## Troubleshooting

### SSH connection failed
```bash
# Kiểm tra SSH key
bash scripts/setup_ssh.sh

# Test SSH thủ công
ssh root@167.172.81.150
```

### Deployment failed
```bash
# Xem logs trên server
ssh root@167.172.81.150 'cd /opt/jwt-java-reactjs && docker compose -f deploy/compose.vps.yml logs'
```

Xem hướng dẫn chi tiết tại: [DEPLOY_VPS.md](DEPLOY_VPS.md)

