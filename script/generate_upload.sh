#!/bin/bash

#rm ../s3/story/*.mp3
#rm ../s3/story/*.json

#title="满招损谦受益"
#title_english="IPride brings loss, humility brings gain"
bucket_name='everyday-story'
csv_key='/home/runner/work/audio/audio/s3/index.csv'
prefix="/home/runner/work/audio/audio/s3"
file_path="/home/runner/work/audio/audio/script/story_original.txt"
title=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
story_chinese=$(sed -n '3p' "$file_path")
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)

get_index() {
    local category="A"
    local year=$(date +'%Y')
    local day_of_year=$(date +'%j')
    local task_time=$(date +'%H:%M:%S')
    local index="${category}_${year}_${day_of_year}_${task_time}"
    echo "$index, $title, $title_english" >> "$csv_key"
    echo "$index"  # Return the index value
}

index_value=$(get_index)  # Call the function and capture the index value
echo "Index value: $index_value"
echo "Title value: $title"

create_json_file() {
    local index="$1"
    local timestamp="$2"
    local story_chinese="$3"

    # Create the JSON content using variables
    local meta_content='{
      "chinese_title": "'"$title"'",
      "english_title": "'"$title_english"'",
      "index": "'"$index_value"'",
      "timestamp": "'"$(date +"%Y-%m-%d %H:%M:%S")"'",
      "story_chinese": "'"$story_chinese"'",
      "story_english": "'"$story_english"'"
      "story_french": "'"$story_french"'"
    }'

    # Write the JSON content to the file
    echo "$meta_content" > "/home/runner/work/audio/audio/s3/story/"$index_value"_meta.json"
    echo "Generated the metadata json file."
}

# Call the function with parameters
create_json_file "$index_value" "$(date +"%Y-%m-%d %H:%M:%S")" "$story_chinese"

generate_speeches() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate 16000 /home/runner/work/audio/audio/s3/story/"$index_value"_chinese.mp3
    aws polly synthesize-speech --text "$story_english" --output-format mp3 --voice-id Matthew --sample-rate 16000 /home/runner/work/audio/audio/s3/story/"$index_value"_english.mp3
    aws polly synthesize-speech --text "$story_french" --output-format mp3 --voice-id Celine --sample-rate 16000 /home/runner/work/audio/audio/s3/story/"$index_value"_french.mp3
}

generate_speeches

upload_files() {
    aws s3 cp $prefix/index.csv s3://everyday-story/index.csv
    aws s3 cp $prefix/story/${index_value}_meta.json s3://everyday-story/story/${index_value}_metadata_${title}.json
    aws s3 cp $prefix/story/${index_value}_chinese.mp3 s3://everyday-story/story/${index_value}_chinese_version_${title}.mp3
    aws s3 cp $prefix/story/${index_value}_english.mp3 s3://everyday-story/story/${index_value}_english_version_${title}.mp3
    aws s3 cp $prefix/story/${index_value}_french.mp3 s3://everyday-story/story/${index_value}_french_version_${title}.mp3
    aws s3api put-object-tagging --bucket $bucket_name --key story/${index_value}_metadata_${title}.json --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}, {Key=metadata,Value=yes}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${index_value}_chinese.mp3 --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${index_value}_english.mp3 --tagging 'TagSet=[{Key=language,Value=english}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/${index_value}_french.mp3 --tagging 'TagSet=[{Key=language,Value=french}, {Key=scope,Value=成语}]'
}

upload_files