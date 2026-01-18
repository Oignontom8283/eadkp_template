#!/bin/bash

# Get the project name from Cargo.toml
PROJECT_NAME=$(cargo metadata --format-version 1 --no-deps | jq -r '.packages[0].name')

# Allow local connections to the X server
xhost +local:docker

docker exec -it "$PROJECT_NAME" bash
