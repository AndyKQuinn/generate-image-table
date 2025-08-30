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

# Validate CALCULATE_TAG format (MM_DD-YYYY-HH_MM)
# if [[ ! "$CALCULATE_TAG" =~ ^[0-9]{2}_[0-9]{2}-[0-9]{4}-[0-9]{2}_[0-9]{2}$ ]]; then
#     echo "Skipping: CALCULATE_TAG '$CALCULATE_TAG' is not in MM_DD-YYYY-HH_MM format"
#     exit 0
# fi

# Extract name from image (part after repo path and before version)
FULL_NAME=$(echo "$IMAGE_VALUE" | sed 's|https://artifactory.example-dns.com/examplerepo/||' | sed 's/-[0-9]*:.*//')
DISPLAY_NAME=$(echo "$FULL_NAME" | awk -F '-' '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')

# Extract version from image name (last part after /)
VERSION=$(echo "$IMAGE_URL" | awk -F '/' '{print $NF}' | sed 's/.*-//')

if [ -z "$CI_PROJECT_DIR" ]; then
    PROJECT_DIR="https://gitlab.exampmle.com/examplerepo/README.md"
else
    PROJECT_DIR="$CI_PROJECT_DIR"
fi

# Create CSV-like table with sorted values
cat > image-list.md << EOF
| Name | Version | Tag | Image URL | README |
|----------|---------|-----|-----------|---------|
| $DISPLAY_NAME | $VERSION | $CALCULATE_TAG | \`$IMAGE_URL\` | \`$PROJECT_DIR\` |
EOF

# CSV handling with duplicate checking and squashing
CSV_FILE="image-list.csv"

# Check if CSV file exists and look for existing entry
if [ -f "$CSV_FILE" ]; then
    # Check if entry with same DISPLAY_NAME and VERSION already exists
    if grep -q "^$DISPLAY_NAME,$VERSION," "$CSV_FILE"; then
        # Entry exists, update it with new values
        # Create temporary file
        temp_file=$(mktemp)

        # Process each line and update matching entry
        while IFS= read -r line; do
            if [[ "$line" =~ ^$DISPLAY_NAME,$VERSION, ]]; then
                # Replace existing line with new values
                echo "$DISPLAY_NAME,$VERSION,$CALCULATE_TAG,$IMAGE_URL,$PROJECT_DIR" >> "$temp_file"
            else
                # Keep existing line unchanged
                echo "$line" >> "$temp_file"
            fi
        done < "$CSV_FILE"

        # Replace original file with updated content
        mv "$temp_file" "$CSV_FILE"
        echo "Updated existing entry for $DISPLAY_NAME version $VERSION in CSV"
    else
        # Entry doesn't exist, append new entry
        echo "$DISPLAY_NAME,$VERSION,$CALCULATE_TAG,$IMAGE_URL,$PROJECT_DIR" >> "$CSV_FILE"
        echo "Added new entry for $DISPLAY_NAME version $VERSION to CSV"
    fi
else
    # CSV file doesn't exist, create it with header and first entry
    echo "Name,Version,Tag,Image URL,README" > "$CSV_FILE"
    echo "$DISPLAY_NAME,$VERSION,$CALCULATE_TAG,$IMAGE_URL,$PROJECT_DIR" >> "$CSV_FILE"
    echo "Created new CSV file with entry for $DISPLAY_NAME version $VERSION"
fi

exit 0
