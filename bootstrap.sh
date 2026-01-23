#!/bin/bash

# Get the directory of the current script
current_dir=$(dirname "$0")

# Determine if the script is being run locally or remotely
if [ -t 0 ]; then
    EXECUTION_SOURCE="local"
else
    EXECUTION_SOURCE="remote"
fi

NAME=""

# Analyze arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) # Argument --name
            NAME="$2"
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

# If script is in work directory
if [ "$current_dir" == "$(pwd)" ]; then
    IS_IN_WORK_DIR=true
    echo "Le projet dans le répertoire courant."
else
    IS_IN_WORK_DIR=false
    echo "The project will be initialized in the directory: $current_dir"
fi

echo "Execution source: $EXECUTION_SOURCE"

