#!/bin/bash

# Get the name of the report folder in the current directory
WORKSPACE_NAME=$(ls -d */ | head -n 1 | cut -f1 -d'/')

# Add the current date and time to the workspace name
TODAYS_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
WORKSPACE_NAME="$WORKSPACE_NAME-$TODAYS_DATE"

# API endpoint URLs
CREATE_WORKSPACE_URL="http://50.19.164.46:3001/api/v1/workspace/new"
UPLOAD_DOCUMENT_URL="http://50.19.164.46:3001/api/v1/workspace/$WORKSPACE_NAME/update-embeddings"

# API key
API_KEY="629MMJT-S334FZ2-HPE8V5S-PGQAWWQ"

# API request body for creating a new workspace
WORKSPACE_BODY=$(cat <<EOF
{
  "name": "$WORKSPACE_NAME",
  "description": "This is a new workspace for $WORKSPACE_NAME."
}
EOF
)

# Send POST request to create a new workspace
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$WORKSPACE_BODY" "$CREATE_WORKSPACE_URL")

# Extract the workspace ID from the response
WORKSPACE_ID=$(echo "$RESPONSE" | jq -r '.id')

# Check if the workspace creation was successful
if [ -z "$WORKSPACE_ID" ]; then
  echo "Failed to create workspace"
  exit 1
fi

echo "Workspace created with ID: $WORKSPACE_ID"

# Upload all files in the reports folder
for FILE_PATH in reports/*; do
  if [ -f "$FILE_PATH" ]; then
    FILE_NAME=$(basename "$FILE_PATH")
    echo "Uploading document: $FILE_NAME"
    UPLOAD_BODY=$(cat <<EOF
    {
      "adds": [
        "$FILE_NAME"
      ],
      "deletes": [
      ]
    }
EOF
)
    # Send POST request to upload the document
    UPLOAD_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$UPLOAD_BODY" "$UPLOAD_DOCUMENT_URL")

    # Check if the document upload was successful
    if [ -z "$UPLOAD_RESPONSE" ]; then
      echo "Failed to upload document: $FILE_NAME"
    else
      echo "Document uploaded successfully: $FILE_NAME"
    fi
  fi
done

echo "All documents uploaded"
