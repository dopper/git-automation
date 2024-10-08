#!/bin/bash

# Check if the --update-git flag is passed
UPDATE_GIT=false
if [[ "$1" == "--update-git" ]]; then
    UPDATE_GIT=true
fi

# Loop over all subdirectories
for dir in */ ; do
    # Check if the subdirectory contains a .git directory (i.e., it's a git repo)
    if [ -d "$dir/.git" ]; then
        echo "Checking repository in directory: $dir"

        # Navigate into the directory
        cd "$dir" || continue

        # Check for uncommitted changes
        if [[ $(git status --porcelain) ]]; then
            echo "Uncommitted changes detected in $dir."

            # If the --update-git flag is passed, add, commit, and push changes
            if $UPDATE_GIT; then
                echo "Staging all changes..."
                git add .

                # Commit the changes with a default message
                echo "Committing changes..."
                git commit -m "Auto-commit: Update repository"

                # Push the changes to the remote repository
                echo "Pushing changes to remote..."
                git push
            fi
        else
            echo "No uncommitted changes in $dir."
        fi

        # Fetch latest changes from remote and check if we're behind
        git fetch
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})

        if [ "$LOCAL" = "$REMOTE" ]; then
            echo "$dir is up to date."
        elif [ "$LOCAL" != "$REMOTE" ]; then
            echo "$dir is not up to date with the remote. Pulling latest changes..."
            git pull
        fi

        # Go back to the parent directory
        cd ..
    else
        echo "$dir is not a git repository."
    fi

    echo ""
done

