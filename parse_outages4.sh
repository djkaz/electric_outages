#!/bin/bash

# Define the RSS feed URL
URL="https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3"

# Temporary files
XML_FILE="/tmp/rssfeed.xml"
OUTPUT_TXT="/tmp/outages_NUCI.txt"
OUTPUT_DOCX="/tmp/outages_NUCI.docx"

# Download the RSS feed
curl -s "$URL" -o "$XML_FILE"

# Check if xmllint is available
if ! command -v xmllint >/dev/null; then
  echo "Error: xmllint not found. Please install libxml2."
  exit 1
fi

# Extract and filter entries containing "NUCI" (uppercase only)
xmllint --format "$XML_FILE" | awk '
  /<item>/,/<\/item>/ {
    if ($0 ~ /<title>/) {
      gsub(/<[^>]+>/, "", $0);
      title = $0;
    }
    if ($0 ~ /<description>/) {
      gsub(/<[^>]+>/, "", $0);
      description = $0;
    }
    if ($0 ~ /<pubDate>/) {
      gsub(/<[^>]+>/, "", $0);
      pubDate = $0;
    }
    if ($0 ~ /<\/item>/) {
      # Only match exact uppercase "NUCI"
      if (title ~ /NUCI/ || description ~ /NUCI/) {
        print "=== OUTAGE INFORMATION ===\nTitle: " title "\nDescription: " description "\nPublished: " pubDate "\n";
        found=1;
      }
      title=""; description=""; pubDate="";
    }
  }
  END {
    if (!found) {
      print "No outages found matching 'NUCI'.";
    }
  }
' > "$OUTPUT_TXT"

echo "Filtered outages containing 'NUCI' have been saved to $OUTPUT_TXT"

# Function to install pandoc
install_pandoc() {
  echo "Attempting to install pandoc..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get >/dev/null; then
      sudo apt-get update && sudo apt-get install -y pandoc
    else
      echo "apt-get not available. Please install pandoc manually."
      return 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew >/dev/null; then
      brew install pandoc
    else
      echo "Homebrew not found. Please install pandoc manually."
      return 1
    fi
  else
    echo "Unsupported OS. Please install pandoc manually."
    return 1
  fi
}

# Ensure pandoc is installed
if ! command -v pandoc >/dev/null; then
  install_pandoc || {
    echo "pandoc installation failed or unsupported system. Skipping DOCX generation."
    exit 0
  }
fi

# Generate Word document
pandoc "$OUTPUT_TXT" -o "$OUTPUT_DOCX"

if [[ -f "$OUTPUT_DOCX" ]]; then
  echo "✅ Word document created at: $OUTPUT_DOCX"
else
  echo "❌ Failed to generate Word document."
fi
