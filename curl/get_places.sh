#!/bin/bash

# This script searches for places using the Foursquare API.
# Default parameters:
# - Query: pizza
# - Location: New Belgrade (latitude: 44.8196, longitude: 20.4251)
# - Radius: 4000 meters
# You can override the default parameters by passing them to the script.

# Default parameters
DEFAULT_QUERY="pizza"
DEFAULT_LAT="44.8196"
DEFAULT_LON="20.4251"
DEFAULT_RADIUS="4000"

# Use script arguments or default values
QUERY=${1:-$DEFAULT_QUERY}
LAT=${2:-$DEFAULT_LAT}
LON=${3:-$DEFAULT_LON}
RADIUS=${4:-$DEFAULT_RADIUS}

# Check if the AUTH_HEADER environment variable is set
if [ -z "$FOURSQUARE_AUTH_HEADER" ]; then
    echo "Error: AUTH_HEADER environment variable is not set"
    exit 1
fi

# Store the authorization header in a variable
AUTH_HEADER="$FOURSQUARE_AUTH_HEADER"

# API endpoint and parameters
URL="https://api.foursquare.com/v3/places/search?query=$QUERY&ll=$LAT,$LON&radius=$RADIUS"

# Make the API request
curl_command="curl -s -f -X GET \"$URL\" -H \"Authorization: $AUTH_HEADER\""
echo "Fetching data from Foursquare API... with command: $curl_command"
response=$(eval $curl_command)

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch data from Foursquare API"
    exit 1
fi

# Format output using jq if available, otherwise output raw JSON
if command -v jq >/dev/null 2>&1; then
    echo "$response" | jq '.'
else
    echo "Note: Install jq for prettier JSON formatting"
    echo "$response"
fi