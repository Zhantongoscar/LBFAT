#!/bin/bash

echo "Stopping containers and removing volumes..."
docker-compose down -v

echo "Cleaning MySQL data directory..."
rm -rf mysql/data/*

echo "Cleaning Neo4j data directory..."
rm -rf neo4j/data/*

echo "Rebuilding and starting main containers..."
docker-compose up --build -d

echo "Waiting for services to be ready..."
sleep 10

echo "Checking container status..."
docker-compose ps

echo "Building and starting neo4j-app (without running)..."
docker-compose --profile tools build neo4j-app

echo "Neo4j application is ready to use. You can start it with:"
echo "docker-compose --profile tools up neo4j-app" 