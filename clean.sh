#!/bin/bash

echo "Stopping containers and removing volumes..."
docker-compose -f /root/project/LBFAT/docker-compose.yml down -v

echo "Cleaning MySQL data directory..."
rm -rf /root/project/LBFAT/mysql/data/*

echo "Rebuilding and starting containers..."
docker-compose -f /root/project/LBFAT/docker-compose.yml up --build -d

echo "Waiting for services to be ready..."
sleep 10

echo "Checking container status..."
docker-compose -f /root/project/LBFAT/docker-compose.yml ps
