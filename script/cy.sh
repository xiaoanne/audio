#!/bin/bash

# Common variable declarations
bucket_name='everyday-story'
file_path="./script/story_original.txt"
local_prefix="./downloads"
sample_rate=24000
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
# ====================Need to update when adding another language==================
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
# category="Chengyu"
# year=$(date +'%Y')
# day_of_year=$(date +'%j')
# task_time=$(date +'%H:%M:%S')

# ====================Need to update when adding another language==================
# Generate index value
# index_value="${category}_${year}_${day_of_year}_${task_time}"
# echo "Index value: ${index_value}"
echo "Title value: ${title_chinese}"
echo "Chinese story: ${story_chinese}"
echo "English story: ${story_english}"
echo "French story: ${story_french}"