#!/bin/bash

# Common variable declarations
bucket_name='everyday-story'
file_path="./script/story_original.txt"
sample_rate=24000
fr_output_file_path="./script/story_french.txt"

# Read titles and story content from the file
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
# Replace non-breaking spaces with regular spaces
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n' | sed 's/\xa0/ /g')

# Translate the Chinese story to English and French
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code auto --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code auto --target-language-code fr --query 'TranslatedText' --output $fr_output_file_path)
aws translate translate-text --text "$story_chinese" --source-language-code auto --target-language-code fr --query 'TranslatedText' --output $fr_output_file_path

# Function to print the Chinese story
get_story() {
  echo "Printing the Chinese story:"
  echo "$story_chinese"
  echo "$story_english"
  echo "$story_french"
}

# Call the print_story function
get_story