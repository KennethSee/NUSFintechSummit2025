#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"

# Run the Python scripts with the provided file path
python pdf2text_blacklist.py --file "$FILE_PATH"
python blacklist_inference.py --input_csv sentences_with_entities.csv --output_txt inferred_blacklisted_countries.txt
python pdf2text_threshold.py --file "$FILE_PATH"
python threshold_inference.py --input_csv sentences_with_entities.csv --output_txt inferred_threshold_countries.txt