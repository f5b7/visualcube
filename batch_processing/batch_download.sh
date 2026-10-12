#!/bin/bash

# Check if exactly 3 arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <URLs_file> <Filenames_file> <Images_output_folder>"
    echo "Example: $0 Example_URLs.txt Example_Filenames.txt Example_Images/"
    echo
    echo "Downloads files from URLs specified in a file and saves them into the given folder, using names from another file."
    echo "Files saved as *.svg will additionally be converted/saved as *.png files if Inkscape is installed."
    exit 1
fi

URL_FILE="$1"
NAME_FILE="$2"
OUTPUT_FOLDER="$3"

# Check if the input files exist
if [ ! -f "$URL_FILE" ]; then
    echo "Error: URL file '$URL_FILE' not found."
    exit 1
fi

if [ ! -f "$NAME_FILE" ]; then
    echo "Error: Name file '$NAME_FILE' not found."
    exit 1
fi

# Create output folder if it does not exist
mkdir -p "$OUTPUT_FOLDER"

# Ensure both files have the same number of lines
URL_LINES=$(wc -l < "$URL_FILE")
NAME_LINES=$(wc -l < "$NAME_FILE")
if [ "$URL_LINES" -ne "$NAME_LINES" ]; then
    echo "Error: URL file and Name file must have the same number of lines."
    exit 1
fi

# Read both files line by line in parallel and store successful SVG ones in an array if Inkscape exists
TARGET_PATHS=()
INKSCAPE=$(which inkscape)
CONVERT=$([[ $INKSCAPE != "" ]])
while IFS=$'\t' read -r URL NAME; do
    if [ -n "$URL" ] && [ -n "$NAME" ]; then
        # Download
        TARGET_PATH="$OUTPUT_FOLDER/$NAME"
        echo "Downloading: $URL -> $TARGET_PATH"
        wget -q --show-progress --tries=3 --timeout=30 -O "$TARGET_PATH" "$URL"

        # Check if the download succeeded
        if [ $? -eq 0 ]; then
            echo "Downloaded $NAME successfully."
            if $CONVERT && [[ $NAME == *.svg ]]; then
                TARGET_PATHS+=("$TARGET_PATH")
                echo "Marked $NAME for conversion."
            fi
        else
            echo "Failed to download $URL."
        fi
    else
        echo "Skipping invalid line or empty URL/name."
    fi
done < <(paste "$URL_FILE" "$NAME_FILE")

echo "All downloads processed."
NUM_CONV=${#TARGET_PATHS[@]}
echo "$NUM_CONV SVG files marked for conversion."

if $CONVERT && [[ $NUM_CONV -gt 0 ]]; then
    echo "Converting the following SVG files to PNG:"
    printf "%s\n" "${TARGET_PATHS[@]}"
    inkscape --export-type=png ${TARGET_PATHS[@]}
    if [ $? -eq 0 ]; then
        echo "Conversion successful."
    fi
fi
