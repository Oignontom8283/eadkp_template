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

# Function to check if a file should be ignored from updates
is_ignored_file() {
    local target="$1"
    
    # Always protect config.env natively, just in case a user removes it from the list by mistake
    if [[ "$target" == "./$DIR_NAME/config.env" ]]; then
        return 0
    fi
    
    # Read comma-separated ignore list
    IFS=',' read -ra IGNORED_ARRAY <<< "$IGNORE_FILES"
    for ignored in "${IGNORED_ARRAY[@]}"; do
        # Trim leading/trailing whitespace
        ignored="${ignored#"${ignored%%[![:space:]]*}"}"
        ignored="${ignored%"${ignored##*[![:space:]]}"}"
        if [[ "$ignored" == "$target" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Function to extract the project name from Cargo.toml and export it
export_project_name() {
    # Match both double and single quotes using sed
    export PROJECT_NAME=$(grep -m 1 '^name *=' Cargo.toml | sed -E "s/^name *= *['\"]([^'\"]+)['\"].*/\1/")

    if [ -z "$PROJECT_NAME" ]; then
        echo "[Error] Could not find the project name in Cargo.toml."
        exit 1
    fi
}