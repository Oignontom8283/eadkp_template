#!/bin/bash

# Default configuration path
CONFIG_FILE=".eadkp/config.env"

# Function to load and validate the configuration file
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[Error] Configuration file $CONFIG_FILE not found."
        echo "Please refer to the documentation to configure your repository."
        exit 1
    fi

    source "$CONFIG_FILE"

    # Validate that all required variables are set
    if [ -z "$REPO" ] || [ -z "$BRANCH" ] || [ -z "$DIR_NAME" ]; then
        echo "[Error] Missing required variables (REPO, BRANCH, DIR_NAME) in $CONFIG_FILE."
        echo "Please check the file and refer to the documentation if needed."
        exit 1
    fi
}

# Function to extract the project name from Cargo.toml and export it
export_project_name() {
    export PROJECT_NAME=$(grep -m 1 '^name *=' Cargo.toml | cut -d '"' -f 2)

    if [ -z "$PROJECT_NAME" ]; then
        echo "[Error] Could not find the project name in Cargo.toml."
        exit 1
    fi
}