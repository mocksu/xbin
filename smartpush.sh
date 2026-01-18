#!/bin/bash

# 1. Handle Deleted Files
# We group all deletions into one commit with the "Current" time
# because deleted files don't have a timestamp to preserve.
deleted_files=$(git ls-files --deleted)
if [ -n "$deleted_files" ]; then
    git add -u
    git commit -m "Remove deleted files"
fi

# 2. Handle Modified & New Files
# We loop through them one by one to save their specific timestamp.
# "IFS= read -r" ensures we handle filenames with spaces correctly.
git ls-files -m -o --exclude-standard | while IFS= read -r file; do
    # Double check file exists
    if [ -f "$file" ]; then
        git add "$file"
        
        # Get the file's modification time (macOS format)
        file_time=$(date -r "$file" "+%Y-%m-%d %H:%M:%S")
        
        # Commit backdated to that specific time
        # We set both Committer Date and Author Date
        GIT_COMMITTER_DATE="$file_time" git commit --date="$file_time" -m "Update $file"
    fi
done

# 3. Push everything to main
git push origin main
