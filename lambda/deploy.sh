#!/bin/bash -eux

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <lambda-folder-name>"
  exit 1
fi

# NOTE:
# % -> remove a suffix
# / -> the extra character to match at the end
# Remove a trailing / if it exists
FUNCTION_NAME=${1%/}

ZIP_FILE="${FUNCTION_NAME}.zip"

echo "Deploying Lambda function: $FUNCTION_NAME"

# Check if folder exists
if [ ! -d "$FUNCTION_NAME" ]; then
  echo "Error: Directory '$FUNCTION_NAME' does not exist."
  exit 1
fi

# Remove old zip if exists
rm -f "$ZIP_FILE"

# Create zip from inside the folder (important for Lambda structure)
cd "$FUNCTION_NAME"
zip -r "../$ZIP_FILE" .
cd ..

echo "Zip created: $ZIP_FILE"

# Update Lambda function
aws lambda update-function-code \
  --function-name "$FUNCTION_NAME" \
  --zip-file "fileb://$ZIP_FILE"

# Remove zip
rm -f "$ZIP_FILE"

echo "Deployment complete!"
