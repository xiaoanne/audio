#!/bin/bash

#rm ../s3/story/*.mp3
#rm ../s3/story/*.json

bucket_name='everyday-story'
echo "pwd is: $(pwd)"
file_path="./script/story_original.txt"
csv_key="./s3/index.csv"
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
story_chinese=$(sed -n '3p' "$file_path")
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)

get_index() {
    local category="Chengyu"
    local year=$(date +'%Y')
    local day_of_year=$(date +'%j')
    local task_time=$(date +'%H:%M:%S')
    local index="${category}_${year}_${day_of_year}_${task_time}"
    echo "$index, $title_chinese, $title_english" >> "$csv_key"
    echo "$index"  # Return the index value
}
index_value=$(get_index)  # Call the function and capture the index value
echo "Index value: $index_value"
echo "Title value: $title_chinese"

story_name_metadata=${index_value}_metadata_${title_chinese}
story_name_chinese=${index_value}_chinese_version_${title_chinese}
story_name_english=${index_value}_english_version_${title_chinese}
story_name_french=${index_value}_french_version_${title_chinese}



generate_books() {
    languages=("chinese" "english" "french")
    titles=("$title_chinese" "$title_english" "$title_english")
    stories=("$story_chinese" "$story_english" "$story_french")
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

    echo "Now uploading books"
    aws s3 cp "./s3/books/chinese_chengyu.txt" s3://everyday-story/books/"chinese_chengyu.txt"
    aws s3 cp "./s3/books/english_chengyu.txt" s3://everyday-story/books/"english_chengyu.txt"
    aws s3 cp "./s3/books/french_chengyu.txt" s3://everyday-story/books/"french_chengyu.txt"

    echo "Now uploading mp3 and metadata json files"
    aws s3 cp "./s3/story/"${story_name_metadata}.json s3://everyday-story/story/${story_name_metadata}.json
    aws s3 cp "./s3/story/"${story_name_chinese}.mp3 s3://everyday-story/story/${story_name_chinese}.mp3
    aws s3 cp "./s3/story/"${story_name_english}.mp3 s3://everyday-story/story/${story_name_english}.mp3
    aws s3 cp "./s3/story/"${story_name_french}.mp3 s3://everyday-story/story/${story_name_french}.mp3

    echo "Now updating s3 objects tags"
    aws s3api put-object-tagging --bucket $bucket_name --key story/${story_name_metadata}.json --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}, {Key=metadata,Value=yes}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${story_name_chinese}.mp3 --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${story_name_english}.mp3 --tagging 'TagSet=[{Key=language,Value=english}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${story_name_french}.mp3 --tagging 'TagSet=[{Key=language,Value=french}, {Key=scope,Value=成语}]'
}

upload_files