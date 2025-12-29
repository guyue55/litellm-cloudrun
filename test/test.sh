#!/bin/bash
set -e

BASE_URL="https://<YOUR-CLOUD-RUN-URL>"
MY_MASTER_KEY="sk-123456"

# Test /v1/models endpoint
echo "Test /v1/models endpoint"
curl -X GET "${BASE_URL}/v1/models" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${MY_MASTER_KEY}"

echo ""
echo "------------------------------------"
echo ""

# Test /v1/chat/completions endpoint
echo "Test /v1/chat/completions endpoint"
curl -X POST "${BASE_URL}/v1/chat/completions" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${MY_MASTER_KEY}" \
-d '{
  "model": "gemini-3-pro-preview",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释量子纠缠"
    }
  ]
}'

