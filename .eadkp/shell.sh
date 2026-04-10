#!/bin/bash

# Source utilities and export project name
source .eadkp/utils.sh
export_project_name

# Allow local connections to the X server (silencing errors if not in a GUI session)
xhost +local:docker >/dev/null 2>&1

# Get the first service name dynamically from docker-compose
SERVICE_NAME=$(docker compose config --services 2>/dev/null | head -n 1)

if [ -z "$SERVICE_NAME" ]; then
    echo "[Error] Could not find any service in docker-compose.yml."
    exit 1
fi

# Execute bash inside the corresponding service container
docker compose exec -it "$SERVICE_NAME" bash
