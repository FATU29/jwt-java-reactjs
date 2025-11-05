# JWT Authentication Application

A full-stack JWT authentication system with React frontend and Spring Boot backend.

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Java 21+
- Maven 3.9+
- PostgreSQL 16+

### Backend Setup

1. **Start PostgreSQL**:
   ```bash
   ./start-postgres.sh
   ```
   Or manually:
   ```bash
   docker run -d --name jwt-postgres \
     -p 5432:5432 \
     -e POSTGRES_DB=jwt_auth \
     -e POSTGRES_USER=jwt_user \
     -e POSTGRES_PASSWORD=jwt_password \
     postgres:16-alpine
   ```

2. **Configure environment** (optional):
   Create `jwt-authentication-be/.env`:
   ```env
   SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/jwt_auth
   SPRING_DATASOURCE_USERNAME=jwt_user
   SPRING_DATASOURCE_PASSWORD=jwt_password
   SPRING_JPA_HIBERNATE_DDL_AUTO=update
   SPRING_JPA_SHOW_SQL=false
   SERVER_PORT=8080
   SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver
   ```

3. **Run the backend**:
   ```bash
   cd jwt-authentication-be
   ./mvnw spring-boot:run
   ```

### Frontend Setup

1. **Install dependencies**:
   ```bash
   cd jwt-authentication-fe
   npm install
   ```

2. **Configure API URL** (optional):
   Create `jwt-authentication-fe/.env`:
   ```env
   VITE_API_BASE_URL=http://localhost:8080
   ```

3. **Run the frontend**:
   ```bash
   npm run dev
   ```

4. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080

## Default Credentials

- **Email**: `admin@example.com`
- **Password**: `password123`

## Tech Stack

- **Frontend**: React 19, TypeScript, Vite, Material-UI, React Query, React Hook Form
- **Backend**: Spring Boot 3.5.7, Spring Security, JWT, PostgreSQL
