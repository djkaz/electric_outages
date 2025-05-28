#!/bin/bash

# Define the RSS feed URL
URL="https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2F20250528%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3"

# Temporary XML file
XML_FILE="/tmp/rssfeed.xml"

# Output text file
OUTPUT_FILE="/tmp/nuci_outages.txt"

# Download the RSS feed
curl -s "$URL" -o "$XML_FILE"

# Check if xmllint is available
if ! command -v xmllint >/dev/null; then
  echo "xmllint not found. Please install libxml2 (e.g., via Homebrew: brew install libxml2)."
  exit 1
fi

# Parse, filter for "Nuci", and write to output file
xmllint --format "$XML_FILE" | awk '
  /<item>/,/<\/item>/ {
    if ($0 ~ /<title>/) {
      title = $0;
      gsub(/<[^>]+>/, "", title);
    }
    if ($0 ~ /<description>/) {
      description = $0;
      gsub(/<[^>]+>/, "", description);
    }
    if ($0 ~ /<pubDate>/) {
      pubDate = $0;
      gsub(/<[^>]+>/, "", pubDate);
    }
    if ($0 ~ /<\/item>/) {
      # Check if "Nuci" is in title or description (case-insensitive)
      if (tolower(title) ~ /nuci/ || tolower(description) ~ /nuci/) {
        print "=== OUTAGE INFORMATION ===\nTitle: " title "\nDescription: " description "\nPublished: " pubDate "\n"
      }
      # Reset variables for next item
      title=""; description=""; pubDate="";
    }
  }
' > "$OUTPUT_FILE"

echo "Filtered output saved to $OUTPUT_FILE"

# # Check for pandoc and show message
# if ! command -v pandoc >/dev/null; then
#   echo "pandoc not found. Please install pandoc to generate Word documents."
# fi
