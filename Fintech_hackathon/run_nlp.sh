#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"
FILE_BASENAME=$(basename "$FILE_PATH" .pdf)  # Get the file name without extension

# Run the Python scripts with the provided file path
python pdf2text_blacklist.py --file "$FILE_PATH"
python blacklist_inference.py --input_csv ./output/sentences_with_entities_blacklist.csv --output_txt ./output/${FILE_BASENAME}/inferred_blacklisted_countries.txt
python pdf2text_threshold.py --file "$FILE_PATH"
python threshold_inference.py --input_csv ./output/sentences_with_entities_threshold.csv --output_txt ./output/${FILE_BASENAME}/inferred_threshold.txt