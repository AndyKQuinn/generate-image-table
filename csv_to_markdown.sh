#!/bin/bash

CSV_FILE="image-list.csv"
OUTPUT_FILE="image-list.md"

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: $CSV_FILE not found!"
    exit 1
fi

echo "Converting $CSV_FILE to Markdown table..."
{
    while IFS=',' read -r name version tag image_url readme; do
        [ -z "$name" ] && continue

        if [ "$name" = "Name" ]; then
            echo "| $name | $version | $tag | $image_url | $readme |"
            echo "|------|----------|-----|------------|---------|"
        else
            echo "| $name | $version | $tag | $image_url | $readme |"
        fi
    done < "$CSV_FILE"
} > "$OUTPUT_FILE"

echo "Markdown table created successfully: $OUTPUT_FILE"
echo ""
echo "Generated Markdown table:"
echo "=========================="
cat "$OUTPUT_FILE"

exit 0
