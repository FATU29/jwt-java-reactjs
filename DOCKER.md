# Docker Setup Guide

This project includes Docker configuration to run both the frontend and backend services together.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

## Quick Start

### Build and Run All Services

```bash
docker-compose up --build
```

This will start:
- **PostgreSQL** database on port `5432`
- **Backend** (Spring Boot) on port `8080`
- **Frontend** (React + Vite) on port `3000`

### Run in Detached Mode

```bash
docker-compose up -d --build
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### Stop Services

```bash
docker-compose down
```

### Stop and Remove Volumes

```bash
docker-compose down -v
```

## Services

### Backend (Spring Boot)
- **Port**: `8080`
- **URL**: http://localhost:8080
- **Health Check**: http://localhost:8080/actuator/health (if actuator is configured)

### Frontend (React + Vite)
- **Port**: `3000`
- **URL**: http://localhost:3000

### PostgreSQL
- **Port**: `5432`
- **Database**: `jwt_auth`
- **Username**: `jwt_user`
- **Password**: `jwt_password`

## Environment Variables

You can customize the configuration by creating a `.env` file in the root directory:

```env
# Database
POSTGRES_DB=jwt_auth
POSTGRES_USER=jwt_user
POSTGRES_PASSWORD=jwt_password

# Backend
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/jwt_auth
SPRING_DATASOURCE_USERNAME=jwt_user
SPRING_DATASOURCE_PASSWORD=jwt_password
```

## Building Individual Services

### Backend Only

```bash
cd jwt-authentication-be
docker build -t jwt-backend .
docker run -p 8080:8080 jwt-backend
```

### Frontend Only

```bash
cd jwt-authentication-fe
docker build -t jwt-frontend .
docker run -p 3000:80 jwt-frontend
```

## Troubleshooting

### Port Already in Use

If a port is already in use, you can change it in `docker-compose.yml`:

```yaml
ports:
  - "8081:8080"  # Change host port from 8080 to 8081
```

### Database Connection Issues

Make sure the backend waits for the database to be ready. The health check in `docker-compose.yml` handles this automatically.

### Frontend Not Connecting to Backend

If running in Docker, update your API base URL to use the backend service name:

```typescript
// In your frontend API config
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'http://localhost:8080'  // For Docker
  : 'http://localhost:8080'; // For local dev
```

## Development vs Production

### Development
- Use `npm run dev` for frontend (hot reload)
- Use `./mvnw spring-boot:run` for backend (hot reload)
- Run PostgreSQL separately or use Docker Compose

### Production
- Use Docker Compose for all services
- Frontend is built and served via Nginx
- Backend runs as a JAR file

