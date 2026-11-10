#!/bin/bash
# Week 7 curl collection for the serverless PropertyLite read path.
# Usage: ./curl-tests.sh https://<api-id>.execute-api.us-east-1.amazonaws.com

API="${1:?Usage: ./curl-tests.sh <invoke-url>}"

echo "1. Existing listing (expect 200 + the Sacramento listing)"
curl -s -w "\nHTTP %{http_code}\n\n" "$API/properties/R100234"

echo "2. Another existing listing (expect 200 + the Fresno listing)"
curl -s -w "\nHTTP %{http_code}\n\n" "$API/properties/R100235"

echo "3. Listing that doesn't exist (expect 404 + not found)"
curl -s -w "\nHTTP %{http_code}\n\n" "$API/properties/R999999"

echo "4. Route that isn't defined (expect 404 from API Gateway)"
curl -s -w "\nHTTP %{http_code}\n\n" "$API/properties"
