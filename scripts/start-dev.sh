#!/bin/bash
cd "$(dirname "$0")/.."
docker-compose up -d
cd frontend && npm run dev &
sleep 2
cd ../backend && npm run dev
