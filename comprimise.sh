#!/bin/bash

# Ga naar de Hugo build directory
cd public || exit

# Maak zowel GZIP als Brotli gecomprimeerde versies van elk bestand
find . -type f \( -iname "*.html" -o -iname "*.css" -o -iname "*.js" -o -iname "*.xml" -o -iname "*.json" -o -iname "*.svg" -o -iname "*.txt" \) | while read -r file; do
    # GZIP compressie
    gzip -k -9 "$file"
    
    # Brotli compressie (indien geïnstalleerd)
    if command -v brotli &> /dev/null; then
        brotli -k -q 11 "$file"
    fi
done

