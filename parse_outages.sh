#!/bin/bash

# Define the RSS feed URL
URL="https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2F20250528%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3"

# Temporary XML file
XML_FILE="/tmp/rssfeed.xml"

# Download the RSS feed
curl -s "$URL" -o "$XML_FILE"

# Check if xmllint is available
if ! command -v xmllint >/dev/null; then
  echo "xmllint not found. Please install libxml2 (e.g., via Homebrew: brew install libxml2)."
  exit 1
fi

# Parse and extract useful information
echo "=== OUTAGE INFORMATION ==="
xmllint --format "$XML_FILE" | awk '
  /<item>/,/<\/item>/ {
    if ($0 ~ /<title>/) {
      gsub(/<[^>]+>/, "", $0);
      print "\nTitle: " $0;
    }
    if ($0 ~ /<description>/) {
      gsub(/<[^>]+>/, "", $0);
      print "Description: " $0;
    }
    if ($0 ~ /<pubDate>/) {
      gsub(/<[^>]+>/, "", $0);
      print "Published: " $0;
    }
  }'

