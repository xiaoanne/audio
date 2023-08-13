#!/bin/bash

bucket_name='everyday-story'
echo "pwd is: $(pwd)"
file_path="./script/story_original.txt"
csv_key="./s3/index.csv"
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
# Download existing books and update them later
#aws s3 sync s3://everyday-story/books ./s3/books



get_index() {
    local category="Chengyu"
    local year=$(date +'%Y')
    local day_of_year=$(date +'%j')
    local task_time=$(date +'%H:%M:%S')
    local index="${category}_${year}_${day_of_year}_${task_time}"
#    echo "$index, $title_chinese, $title_english" >> "$csv_key"
#    echo "$new_content" | aws s3 cp - "s3://$bucket_name/$object_key"
    echo "$index, $title_chinese, $title_english" | aws s3 cp - "s3://$bucket_name/$csv_key"
    echo "$index"  # Return the index value
}
index_value=$(get_index)  # Call the function and capture the index value
echo "Index value: $index_value"
echo "Title value: $title_chinese"

story_name_metadata=${index_value}_metadata_${title_chinese}
story_name_chinese=${index_value}_chinese_version_${title_chinese}
story_name_english=${index_value}_english_version_${title_chinese}
story_name_french=${index_value}_french_version_${title_chinese}
languages=("chinese" "english" "french")
titles=("$title_chinese" "$title_english" "$title_english")
stories=("$story_chinese" "$story_english" "$story_french")



generate_books() {
    break_line=""
    for i in "${!languages[@]}"; do
        lang="${languages[$i]}"
        title="${titles[$i]}"
        story="${stories[$i]}"

        echo "The title is: $title" >> "./s3/books/${lang}_chengyu.txt"
        echo "The story content is: $story" >> "./s3/books/${lang}_chengyu.txt"
        echo "$break_line" >> "./s3/books/${lang}_chengyu.txt"
    done
}
generate_books



create_json_file() {
    # Create the JSON content using variables
    local meta_content='{
      "chinese_title": "'"$title_chinese"'",
      "english_title": "'"$title_english"'",
      "index": "'"$index_value"'",
      "timestamp": "'"$(date +"%Y-%m-%d %H:%M:%S")"'",
      "story_chinese": "'"$story_chinese"'",
      "story_english": "'"$story_english"'"
      "story_french": "'"$story_french"'"
    }'

    # Write the JSON content to the file
    echo "$meta_content" > "./s3/story/"$story_name_metadata".json"
    echo "Generated the metadata json file."
}
create_json_file



generate_speeches() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate 16000 "./s3/story/"${story_name_chinese}.mp3
    aws polly synthesize-speech --text "$story_english" --output-format mp3 --voice-id Matthew --sample-rate 16000 "./s3/story/"${story_name_english}.mp3
    aws polly synthesize-speech --text "$story_french" --output-format mp3 --voice-id Celine --sample-rate 16000 "./s3/story/"${story_name_french}.mp3
}
generate_speeches


upload_files() {
    aws s3 cp "./s3"/index.csv s3://everyday-story/index.csv

    declare -a book_languages=("chinese" "english" "french")
    declare -a story_types=("metadata" "chinese_version" "english_version" "french_version")

    for lang in "${book_languages[@]}"; do
        echo "Now uploading $lang book"
        aws s3 cp "./s3/books/${lang}_chengyu.txt" "s3://everyday-story/books/${lang}_chengyu.txt"
    done

    for type in "${story_types[@]}"; do
        echo "Now uploading mp3 and ${type} json files"
        aws s3 cp "./s3/story/${index_value}_${type}_${title_chinese}.json" "s3://everyday-story/story/${index_value}_${type}_${title_chinese}.json"
        aws s3 cp "./s3/story/${index_value}_${type}_${title_chinese}.mp3" "s3://everyday-story/story/${index_value}_${type}_${title_chinese}.mp3"

        echo "Now updating s3 objects tags"
        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_${type}_${title_chinese}.json" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}, {Key=metadata,Value=yes}]'
        aws s3api put-object-tagging --bucket $bucket_name --key "story/${index_value}_${type}_${title_chinese}.mp3" --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
    done
}
#upload_files