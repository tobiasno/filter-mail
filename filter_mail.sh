#!/bin/bash

# Path to killfile - one search term per line
KILLFILE="$HOME/killfile"

# Check if killfile exists
if [ ! -f "$KILLFILE" ]; then
    echo "Killfile not found at $KILLFILE"
    exit 1
fi

# Build the combined search query
search_query=""
first=true

while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Add OR operator between terms, except for the first one
    if [ "$first" = true ]; then
        search_query="($line)"
        first=false
    else
        search_query="$search_query or ($line)"
    fi
done < "$KILLFILE"

# If we found any search terms, execute the tag command
if [ -n "$search_query" ]; then
    echo "Filtering messages matching: $search_query"
    notmuch tag -inbox +deleted -- "($search_query) and tag:inbox"
else
    echo "No valid search terms found in killfile"
fi
