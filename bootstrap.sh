#!/bin/bash

PATH_GIVED=""

# Analyze arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) # Argument --name
            PATH_GIVED="$2"
            shift 2
            ;;
        --help) # Display help
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --name <value>    Name of the project"
            echo "  --help            Display this help message"
            exit 0
            ;;
        *) # Unknown argument
            echo "Unknown argument: $1"
            echo "Use --help to see available options."
            exit 1
            ;;
    esac
done

echo ""
echo "Starting the project initialization script via eadkp template..."

# Determine if the script is being run locally or remotely
EXECUTION_SOURCE=$([[ -t 0 ]] && echo "local" || echo "remote")

echo "Execution source: $EXECUTION_SOURCE"


# If no name provided, prompt the user for it
# exept if the script is run locally from its own directory
if [[ -z "$PATH_GIVED" ]]; then
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
    if [[ "$EXECUTION_SOURCE" == "local" && "$SCRIPT_DIR" == "$(pwd)"]]; then
        IS_AUTO_BUILDING=true
        PATH_GIVED="$SCRIPT_DIR"
    else
        read -p "Please enter the project name: " PATH_GIVED
    fi
fi

# Convert to absolute path
PATH_GIVED="$(realpath "$PATH_GIVED")"
PROJECT_NAME="$(basename "$PATH_GIVED")"

echo ""
echo "Project name: $PROJECT_NAME"
echo "Project will be initialized at: $PATH_GIVED"
echo ""

# Create project directory recursively, if it does not exist
mkdir -p "$PATH_GIVED"

# Check if the directory is empty
if [ -n "$(ls -A "$PATH_GIVED")" ]; then
    echo "Error: The directory '$PATH_GIVED' is not empty. Please choose an empty directory."
    exit 1
fi

