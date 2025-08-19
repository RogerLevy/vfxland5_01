# Snapshot Command

Create a new snapshot-stable tag with an incrementing number and push it to origin.

## Usage
```
/snapshot
```

## Implementation
```bash
# Get the latest snapshot-stable tag number
LATEST_TAG=$(git tag -l "snapshot-stable-*" | sort -V | tail -1)

if [ -z "$LATEST_TAG" ]; then
    # No existing snapshot-stable tags, start with 001
    NEW_NUMBER="001"
else
    # Extract the number from the latest tag and increment it
    CURRENT_NUMBER=$(echo "$LATEST_TAG" | sed 's/snapshot-stable-//')
    NEW_NUMBER=$(printf "%03d" $((10#$CURRENT_NUMBER + 1)))
fi

NEW_TAG="snapshot-stable-${NEW_NUMBER}"

echo "Creating tag: $NEW_TAG"

# Create the tag
if git tag "$NEW_TAG"; then
    echo "Tag created successfully"
    # Push the tag to origin
    if git push origin "$NEW_TAG"; then
        echo "Tag $NEW_TAG created and pushed to origin"
    else
        echo "ERROR: Failed to push tag to origin"
        exit 1
    fi
else
    echo "ERROR: Failed to create tag"
    exit 1
fi
```