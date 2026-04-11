#!/bin/bash

# Enclosing the entire script in a block ensures Bash loads everything 
# into memory before executing, preventing issues if the script changes itself.
{

# Load external configuration if present
source .eadkp/utils.sh
load_config

# Safety check to prevent running the script directly from within its folder
if [[ "$(basename "$PWD")" == "$DIR_NAME" ]]; then
    echo "[Safety] Please run the update script from the root directory of the project."
    exit 1
fi

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

# Extract file names, shas and types using grep/cut to completely avoid the 'jq' dependency
names=( $(echo "$json_response" | grep '"name":' | cut -d'"' -f4) )
shas=( $(echo "$json_response" | grep '"sha":' | cut -d'"' -f4) )
types=( $(echo "$json_response" | grep '"type":' | cut -d'"' -f4) )

for i in "${!names[@]}"; do
    if [[ "${types[$i]}" == "file" ]]; then
        file_hashes["${names[$i]}"]="${shas[$i]}"
    fi
done

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
    if is_ignored_file "./$DIR_NAME/$file"; then
        # Skip the ignored file from being overwritten by remote templates
        continue
    fi

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

# Ensure all scripts remain executable
chmod +x "$DIR_NAME"/*.sh 2>/dev/null || true

# 2. Check local files (to delete if not present on the remote)
for file in "${!local_file_hashes[@]}"; do
    if is_ignored_file "./$DIR_NAME/$file"; then
        # Ensure our local ignored files are never deleted even if absent from remote
        continue
    fi

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

# Verify and auto-restore the root launchers
echo ""
echo "[Launchers] Verifying root launchers..."

# Fetch the root directory content 
root_json_response=$(curl -s -f "https://api.github.com/repos/$REPO/contents/?ref=$BRANCH" || echo "[]")

# Extract all names ending with .sh (using grep to avoid jq)
root_sh_scripts=$(echo "$root_json_response" | grep '"name":' | cut -d'"' -f4 | grep '\.sh$' || true)

for launcher in $root_sh_scripts; do
    if is_ignored_file "./$launcher"; then
        continue
    fi

    curl -s -L -o "$launcher.tmp" "https://raw.githubusercontent.com/$REPO/$BRANCH/$launcher"
    if [ -f "$launcher" ]; then
        if ! cmp -s "$launcher.tmp" "$launcher"; then
            echo "[Launchers] Updating modified root launcher: $launcher"
            mv "$launcher.tmp" "$launcher"
            chmod +x "$launcher"
        else
            rm -f "$launcher.tmp"
        fi
    else
        echo "[Launchers] Restoring missing root launcher: $launcher"
        mv "$launcher.tmp" "$launcher"
        chmod +x "$launcher"
    fi
done


# Final message

echo ""
echo "Updating process completed successfully!"
echo ""

}
exit 0