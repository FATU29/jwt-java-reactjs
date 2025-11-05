#!/bin/bash

# Script to start PostgreSQL and pgAdmin for local development

echo "Starting PostgreSQL and pgAdmin for local development..."

# Start PostgreSQL container
if [ "$(docker ps -aq -f name=jwt-postgres-dev)" ]; then
    echo "PostgreSQL container already exists."
    
    if [ "$(docker ps -q -f name=jwt-postgres-dev)" ]; then
        echo "PostgreSQL is already running."
    else
        echo "Starting PostgreSQL container..."
        docker start jwt-postgres-dev
    fi
else
    echo "Creating and starting PostgreSQL container..."
    docker run -d \
        --name jwt-postgres-dev \
        -p 5432:5432 \
        -e POSTGRES_DB=jwt_auth \
        -e POSTGRES_USER=jwt_user \
        -e POSTGRES_PASSWORD=jwt_password \
        -v jwt-postgres-data:/var/lib/postgresql/data \
        postgres:16-alpine
fi

# Start pgAdmin container
if [ "$(docker ps -aq -f name=pgadmin-dev)" ]; then
    echo "pgAdmin container already exists."
    
    if [ "$(docker ps -q -f name=pgadmin-dev)" ]; then
        echo "pgAdmin is already running."
    else
        echo "Starting pgAdmin container..."
        docker start pgadmin-dev
    fi
else
    echo "Creating and starting pgAdmin container..."
    docker run -d \
        --name pgadmin-dev \
        -p 5050:80 \
        -e PGADMIN_DEFAULT_EMAIL=admin@admin.com \
        -e PGADMIN_DEFAULT_PASSWORD=admin \
        -v pgadmin-data:/var/lib/pgadmin \
        dpage/pgadmin4:latest
fi

echo ""
echo "✅ Services are ready!"
echo ""
echo "PostgreSQL:"
echo "  - Host: localhost:5432"
echo "  - Database: jwt_auth"
echo "  - Username: jwt_user"
echo "  - Password: jwt_password"
echo ""
echo "pgAdmin:"
echo "  - URL: http://localhost:5050"
echo "  - Email: admin@admin.com"
echo "  - Password: admin"
echo ""
echo "To stop: docker stop jwt-postgres-dev pgadmin-dev"
echo "To remove: docker rm jwt-postgres-dev pgadmin-dev"
