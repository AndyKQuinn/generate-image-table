#!/bin/bash

if [ ! -f "README.md" ]; then
    echo "Error: README.md not found in current directory"
    exit 1
fi

IMAGE_VALUE=$(awk -F'"' '/"image":/ {print $4}' README.md)

IMAGE_URL=$(echo "$IMAGE_VALUE" | sed 's/:[^:]*$//')

CALCULATE_TAG="08_30_2025-12_00"

if [ -z "$IMAGE_VALUE" ]; then
    echo "Error: Could not find 'image' key in README.md"
    exit 1
fi

FULL_NAME=$(echo "$IMAGE_VALUE" | sed 's|https://artifactory.example-dns.com/examplerepo/||' | sed 's/-[0-9]*:.*//')
DISPLAY_NAME=$(echo "$FULL_NAME" | awk -F '-' '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')

VERSION=$(echo "$IMAGE_URL" | awk -F '/' '{print $NF}' | sed 's/.*-//')

if [ -z "$CI_PROJECT_DIR" ]; then
    PROJECT_DIR="https://gitlab.exampmle.com/examplerepo/README.md"
else
    PROJECT_DIR="$CI_PROJECT_DIR"
fi

CSV_FILE="image-list.csv"
HEADERS="Name,Version,Tag,Image URL,README"
LINE="$DISPLAY_NAME,$VERSION,$CALCULATE_TAG,$IMAGE_URL,$PROJECT_DIR"

if [ -f "$CSV_FILE" ]; then
    if grep -q "^$DISPLAY_NAME,$VERSION," "$CSV_FILE"; then
        temp_file=$(mktemp)

        while IFS= read -r line; do
            if [[ "$line" =~ ^$DISPLAY_NAME,$VERSION, ]]; then
                echo "$LINE" >> "$temp_file"
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$CSV_FILE"

        mv "$temp_file" "$CSV_FILE"
        echo "Updated existing entry for $DISPLAY_NAME version $VERSION in CSV"
    else
        echo "$LINE" >> "$CSV_FILE"
        echo "Added new entry for $DISPLAY_NAME version $VERSION to CSV"
    fi
else
    echo "$HEADERS" > "$CSV_FILE"
    echo "$LINE" >> "$CSV_FILE"
    echo "Created new CSV file with entry for $DISPLAY_NAME version $VERSION"
fi

exit 0
