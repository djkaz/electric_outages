#!/bin/bash

# RSS feed URL
URL="https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2F20250528%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3"

# Temp file for RSS feed
XML_FILE="/tmp/rssfeed.xml"

# Download RSS feed
curl -s "$URL" -o "$XML_FILE"

if ! command -v xmllint >/dev/null; then
  echo "xmllint is required. Install with: brew install libxml2"
  exit 1
fi

# Extract items, filter those containing "Nuci jud Ilfov"
MATCHES=$(xmllint --format "$XML_FILE" | awk '
  BEGIN { RS="</item>"; ORS=""; found=0 }
  /<item>/ {
    item = $0 RS
    if (item ~ /Nuci jud Ilfov/) {
      # Extract title
      match(item, /<title>([^<]*)<\/title>/, t)
      # Extract description
      match(item, /<description>([^<]*)<\/description>/, d)
      # Extract pubDate
      match(item, /<pubDate>([^<]*)<\/pubDate>/, p)
      
      print "Title: " t[1] "\nDescription: " d[1] "\nPublished: " p[1] "\n\n"
      found=1
    }
  }
  END {
    if (found == 0) exit 2
  }
')

if [ $? -eq 2 ]; then
  echo "No outages found for 'Nuci jud Ilfov'. No email sent."
  exit 0
fi

# Prepare email content
EMAIL_SUBJECT="Alert: Power Outages in Nuci jud Ilfov"
EMAIL_BODY="Dear Alex,\n\nHere are the latest power outage notifications for Nuci jud Ilfov:\n\n$MATCHES\nRegards,\nAutomated Alert System"

# Send email (using mail command)
if command -v mail >/dev/null; then
  echo -e "$EMAIL_BODY" | mail -s "$EMAIL_SUBJECT" alex.tiron@direwolf.ro
  echo "Email sent to alex.tiron@direwolf.ro"
else
  echo "The 'mail' command is not installed. To install on macOS: brew install mailutils or use another mail client."
  echo -e "$EMAIL_BODY"
fi

