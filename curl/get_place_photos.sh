#!/bin/bash

# This script fetches photos for a specific place using the Foursquare API
# and constructs valid image URLs.

# Default place ID (Pizza Bar)
DEFAULT_PLACE_ID="4ea1ad6fd3e32e6867a62ed9"

# Use the first script argument as the place ID, or default to the pizza bar ID
PLACE_ID=${1:-$DEFAULT_PLACE_ID}

# Check if the AUTH_HEADER environment variable is set
if [ -z "$FOURSQUARE_AUTH_HEADER" ]; then
    echo "Error: AUTH_HEADER environment variable is not set"
    exit 1
fi

# Store the authorization header in a variable
AUTH_HEADER="$FOURSQUARE_AUTH_HEADER"

# API endpoint for photos
URL="https://api.foursquare.com/v3/places/$PLACE_ID/photos"

# Make the API request
curl_command="curl -s -f -X GET \"$URL\" -H \"Authorization: $AUTH_HEADER\""
echo "Fetching photos for place ID $PLACE_ID from Foursquare API... with command: $curl_command"
response=$(eval $curl_command)

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch data from Foursquare API"
    exit 1
fi

# Format and construct valid image URLs
if command -v jq >/dev/null 2>&1; then
    echo "$response" | jq -r '.[] | "\(.prefix)original\(.suffix)"'
else
    echo "Note: Install jq for prettier JSON formatting"
    echo "$response" | grep -E '"prefix"|"suffix"' | awk -F ': ' '{print $2}' | sed 's/[",]//g'
fi
