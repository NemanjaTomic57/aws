#!/bin/bash -eu

PAYLOAD=$(base64 -w 0 payload.json)

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

echo "Lambda metadata response:"
aws lambda invoke --function-name apiGatewayIntegration --payload "$PAYLOAD" output.json | jq

echo
echo "Lambda function response:"
cat output.json | jq
echo
