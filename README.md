# Dev Container Image

## Usage

- Run `sh get_image_details.sh` to update the `image-list.csv` file
- Run `sh csv_to_markdown.sh` to process CSV into a Markdown table.
- Serve `image-list.html` in a web server.
- Import `image-list.csv`

```json
{
  "name": "My Node Dev Container",
  "image": "https://artifactory.com/examplerepo/node-dev-container-22:08_30_2025-12_00"
}
```
