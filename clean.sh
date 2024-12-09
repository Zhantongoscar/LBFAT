#!/bin/bash

echo "Stopping containers and removing volumes..."
docker-compose down -v

echo "Cleaning MySQL data directory..."
rm -rf mysql/data/*

echo "Rebuilding and starting containers..."
docker-compose up --build -d

echo "Waiting for services to be ready..."
sleep 10

echo "Checking container status..."
docker-compose ps 