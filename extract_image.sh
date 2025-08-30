#!/bin/bash

if [ ! -f "README.md" ]; then
    echo "Error: README.md not found in current directory"
    exit 1
fi

IMAGE_VALUE=$(awk -F'"' '/"image":/ {print $4}' README.md)

IMAGE_URL=$(echo "$IMAGE_VALUE" | sed 's/:[^:]*$//')

if [ -z "$IMAGE_VALUE" ]; then
    echo "Error: Could not find 'image' key in README.md"
    exit 1
fi

echo "Image URL (without tag): $IMAGE_URL"

exit 0
