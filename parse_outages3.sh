#!/bin/bash

# Define the RSS feed URL
URL="https://ppcro-rer-prod-ap01918-production-s3-integration.s3.eu-central-1.amazonaws.com/re_public_outages/outageapp_rss/rssfeed.xml?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3FLDXZGG66KTYMJ2%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250528T212624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=f907f9b937f142bb0217631bd0180e21596032e001881beba0bb3351eea81ff3"

# Temporary XML file and outputs
XML_FILE="/tmp/rssfeed.xml"
OUTPUT_TXT="/tmp/outages_nuci.txt"
OUTPUT_DOCX="/tmp/outages_nuci.docx"

# Download the RSS feed
curl -s "$URL" -o "$XML_FILE"

# Check if xmllint is available
if ! command -v xmllint >/dev/null; then
  echo "xmllint not found. Please install libxml2 (e.g., via Homebrew: brew install libxml2)."
  exit 1
fi

# Extract and filter entries containing "Nuci" (case-insensitive)
xmllint --format "$XML_FILE" | awk '
  BEGIN {IGNORECASE=1; found=0;}
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
      if (title ~ /nuci/ || description ~ /nuci/) {
        print "=== OUTAGE INFORMATION ===\nTitle: " title "\nDescription: " description "\nPublished: " pubDate "\n";
        found=1;
      }
      title=""; description=""; pubDate="";
    }
  }
  END {
    if (!found) {
      print "No outages found matching '\''Nuci'\''.";
    }
  }
' > "$OUTPUT_TXT"

echo "Filtered outages containing 'Nuci' have been saved to $OUTPUT_TXT"

# Function to install pandoc depending on OS
install_pandoc() {
  echo "Attempting to install pandoc..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - try apt-get
    if command -v apt-get >/dev/null; then
      sudo apt-get update && sudo apt-get install -y pandoc
    else
      echo "Could not find apt-get package manager. Please install pandoc manually."
      return 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - try brew
    if command -v brew >/dev/null; then
      brew install pandoc
    else
      echo "Homebrew not found. Please install Homebrew and then pandoc manually."
      return 1
    fi
  else
    echo "Unsupported OS. Please install pandoc manually."
    return 1
  fi
}

# Check for pandoc and install if missing
if ! command -v pandoc >/dev/null; then
  install_pandoc || {
    echo "pandoc installation failed or not supported. Cannot generate Word document."
    exit 0
  }
fi

# Generate Word document from the text output
pandoc "$OUTPUT_TXT" -o "$OUTPUT_DOCX"

if [[ -f "$OUTPUT_DOCX" ]]; then
  echo "Word document generated at $OUTPUT_DOCX"
else
  echo "Failed to generate Word document."
fi
