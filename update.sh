#!/bin/bash

# Enclosing the entire script in a block ensures Bash loads everything 
# into memory before executing, preventing issues if the script changes itself.
{

REPO="Oignontom8283/eadkp_template"
BRANCH="main"
DIR_NAME=".eadkp"

# Get the list of files (name and hash) in the '$DIR_NAME' folder from the repo https://github.com/$REPO.git

# Declare a dictionary (associative array in bash)
declare -A file_hashes

# Request the GitHub API to get the folder content
# The -f option ignores HTTP errors (like 404) and returns an empty array
json_response=$(curl -s -f "https://api.github.com/repos/$REPO/contents/$DIR_NAME?ref=$BRANCH" || echo "[]")

if [[ "$json_response" == "[]" ]]; then
    echo "[Remote] ERROR: The $DIR_NAME folder is empty or does not exist."
    exit 0
fi

# Iterate over the JSON response with jq to extract the name and sha (hash) of each file
while IFS=$'\t' read -r name sha; do
    if [[ -n "$name" ]]; then
        file_hashes["$name"]="$sha"
    fi
done < <(echo "$json_response" | jq -r 'if type=="array" then .[] | select(.type=="file") | [.name, .sha] | @tsv else empty end')

# # Display the dictionary content to verify the results
# for file in "${!file_hashes[@]}"; do
#     echo "$file: ${file_hashes[$file]}"
# done


# Get the list of files (name and hash) in the local '$DIR_NAME' folder
declare -A local_file_hashes

if [[ -d "$DIR_NAME" ]]; then
    for filepath in "$DIR_NAME"/*; do
        if [[ -f "$filepath" ]]; then
            filename=$(basename "$filepath")
            # git hash-object calculates the SHA-1 exactly like GitHub
            local_sha=$(git hash-object "$filepath")
            local_file_hashes["$filename"]="$local_sha"
        fi
    done
else
    echo "[Local] ERROR: The folder $DIR_NAME does not exist."
fi

# # Display the local dictionary content
# for file in "${!local_file_hashes[@]}"; do
#     echo "$file: ${local_file_hashes[$file]}"
# done


# Compare the two dictionaries
# If a file was modified, replace it;
# If it doesn't exist, download it; If it doesn't exist on the remote, delete it.
# Display the actions performed for each file

# Create the local folder if it doesn't exist so we can write into it
mkdir -p "$DIR_NAME"

# 1. Check remote files (to download or update)
for file in "${!file_hashes[@]}"; do
    remote_sha="${file_hashes[$file]}"
    local_sha="${local_file_hashes[$file]}"

    if [[ -z "$local_sha" ]]; then
        echo "[Updating] Downloading new file: $file"
        curl -s -L -o "$DIR_NAME/$file" "https://raw.githubusercontent.com/$REPO/$BRANCH/$DIR_NAME/$file"
    elif [[ "$remote_sha" != "$local_sha" ]]; then
        echo "[Updating] Updating modified file: $file"
        curl -s -L -o "$DIR_NAME/$file" "https://raw.githubusercontent.com/$REPO/$BRANCH/$DIR_NAME/$file"
    else
        echo "[Updating] The file $file is up to date."
    fi
done

# 2. Check local files (to delete if not present on the remote)
for file in "${!local_file_hashes[@]}"; do
    if [[ -z "${file_hashes[$file]}" ]]; then
        echo "[Updating] Deleting file that no longer exists on the remote: $file"
        rm -f "$DIR_NAME/$file"
    fi
done


# Update Cargo dependencies

echo "[Dependencies] Updating Cargo dependencies..."

if just --yes update; then
    echo "[Dependencies] Cargo dependencies updated successfully."
else
    echo "[Dependencies] ERROR: Failed to update Cargo dependencies."
    exit 1
fi


# Final message

echo ""
echo "Updating process completed successfully!"
echo ""

}
exit 0