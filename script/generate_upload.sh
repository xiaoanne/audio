#!/bin/bash

# Common variable declarations
bucket_name='everyday-story'
file_path="./script/story_original.txt"
local_prefix="./downloads"
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
category="Chengyu"
year=$(date +'%Y')
day_of_year=$(date +'%j')
task_time=$(date +'%H:%M:%S')

# Generate index value
index_value="${category}_${year}_${day_of_year}_${task_time}"
echo "Index value: $index_value"
echo "Title value: $title_chinese"


# Download existing books and index.csv, update them later then upload them
aws s3 sync s3://${bucket_name} downloads --exclude "story/*"




## shellcheck disable=SC2034
#story_name_metadata=${index_value}_metadata_${title_chinese}
## shellcheck disable=SC2034
#story_name_chinese=${index_value}_chinese_version_${title_chinese}
## shellcheck disable=SC2034
#story_name_english=${index_value}_english_version_${title_chinese}
## shellcheck disable=SC2034
#story_name_french=${index_value}_french_version_${title_chinese}
languages=("chinese" "english" "french")
# Declare the arrays for function of upload_files
declare -a book_languages=("chinese" "english" "french")
declare -a story_types=("chinese_version" "english_version" "french_version")
# Declare the arrays and other variables outside of the function generate_books
titles=("$title_chinese" "$title_english" "$title_english")
stories=("$story_chinese" "$story_english" "$story_french")

# Create books in multiple language
generate_books() {
    local local_prefix="$1"  # Get the local prefix from the function argument
    break_line=""

    for i in "${!languages[@]}"; do
        lang="${languages[$i]}"
        title="${titles[$i]}"
        story="${stories[$i]}"

        # shellcheck disable=SC2129
        echo "The title is: $title" >> "${local_prefix}/books/${lang}_chengyu.txt"
        echo "The story content is: $story" >> "${local_prefix}/books/${lang}_chengyu.txt"
        echo "$break_line" >> "${local_prefix}/books/${lang}_chengyu.txt"
    done
}
generate_books "${local_prefix}"



create_json_file() {
    # Create the JSON content using variables and Write the JSON content to the file
    local meta_content='{
      "chinese_title": "'"$title_chinese"'",
      "english_title": "'"$title_english"'",
      "index": "'"$index_value"'",
      "timestamp": "'"$(date +"%Y-%m-%d %H:%M:%S")"'",
      "story_chinese": "'"$story_chinese"'",
      "story_english": "'"$story_english"'"
      "story_french": "'"$story_french"'"
    }'

    echo "$meta_content" > "${local_prefix}/story/${index_value}_metadata_${title_chinese}.json"
    echo "Generated the metadata json file."
}
create_json_file



generate_speeches() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate 16000 "${local_prefix}/story/${index_value}_chinese_version_${title_chinese}.mp3"
    aws polly synthesize-speech --text "$story_english" --output-format mp3 --voice-id Matthew --sample-rate 16000 "${local_prefix}/story/${index_value}_english_version_${title_chinese}.mp3"
    aws polly synthesize-speech --text "$story_french" --output-format mp3 --voice-id Celine --sample-rate 16000 "${local_prefix}/story/${index_value}_french_version_${title_chinese}.mp3"
}
generate_speeches

ls -R

# Upload books, index file, mp3 audio and metadata json files into s3 bucket
upload_files() {
    local local_prefix="$1" # Get the local prefix from the function argument
    echo "Now write to index.csv and upload the index.csv file."
    echo "${index_value}, ${title_chinese}, ${title_english}" >> "${local_prefix}/index.csv"
    aws s3 cp "${local_prefix}"/index.csv s3://everyday-story/index.csv

    echo "Now uploading the metadata json file."
    aws s3 cp "${local_prefix}/story/${index_value}_metadata_${title_chinese}.json" "s3://everyday-story/story/${index_value}_metadata_${title_chinese}.json"

    for lang in "${book_languages[@]}"; do
        echo "Now uploading $lang book."
        aws s3 cp "${local_prefix}/books/${lang}_chengyu.txt" "s3://everyday-story/books/${lang}_chengyu.txt"
    done

    echo "Now uploading mp3 files."
    for type in "${story_types[@]}"; do
        echo "Now uploading ${type} mp3 files."
        aws s3 cp "${local_prefix}/story/${index_value}_${type}_${title_chinese}.mp3" "s3://everyday-story/story/${index_value}_${type}_${title_chinese}.mp3"
    done

    echo "Now updating file tags."
    for type in "${story_types[@]}"; do
        echo "Now updating s3 objects tags"
        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_metadata_${title_chinese}.json" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}, {Key=metadata,Value=yes}]'
        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_${type}_${title_chinese}.mp3" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
    done
}
upload_files "${local_prefix}"



#update_tags() {
#    local local_prefix="$1" # Get the local prefix from the function argument
#
#    for type in "${story_types[@]}"; do
#        echo "Now updating s3 objects tags"
#        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_metadata_${title_chinese}.json" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}, {Key=metadata,Value=yes}]'
#        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_${type}_${title_chinese}.mp3" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
#    done
#}
#update_tags "${local_prefix}"