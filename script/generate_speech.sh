#!/bin/bash

#rm ../s3/story/*.mp3
#rm ../s3/story/*.json

title="揠苗助长"
bucket_name='everyday-story'
csv_key='../s3/index.csv'

function get_index() {
    local category="A"
    local year=$(date +'%Y')
    local day_of_year=$(date +'%j')
    local task_time=$(date +'%H:%M:%S')
    local index="${category}_${year}_${day_of_year}_${task_time}"
    echo "$index, $title" >> "$csv_key"
    echo "$index"  # Return the index value
}



index_value=$(get_index)  # Call the function and capture the index value

echo "Index value: $index_value"
echo "Title value: $title"

# Read the value from the file into a variable
file_path="story_original.txt"

story_chinese=$(cat $file_path)
story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)


function create_json_file() {
    local index="$1"
    local timestamp="$2"
    local story_chinese="$3"

    # Create the JSON content using variables
    local meta_content='{
      "index": "'"$index_value"'",
      "timestamp": "'"$(date +"%Y-%m-%d %H:%M:%S")"'",
      "story_chinese": "'"$story_chinese"'",
      "story_english": "'"$story_english"'"
      "story_french": "'"$story_french"'"
    }'

    # Write the JSON content to the file
    echo "$meta_content" > "../s3/story/"$index_value"_meta.json"

    # Display a message
    echo "Generated the metadata json file."
}

# Call the function with parameters

create_json_file "$index_value" "$(date +"%Y-%m-%d %H:%M:%S")" "$story_chinese"

function generate_speech() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate 16000 ../s3/story/"$index_value"_chinese.mp3
    aws polly synthesize-speech --text "$story_english" --output-format mp3 --voice-id Matthew --sample-rate 16000 ../s3/story/"$index_value"_english.mp3
    aws polly synthesize-speech --text "$story_french" --output-format mp3 --voice-id Celine --sample-rate 16000 ../s3/story/"$index_value"_french.mp3
}

generate_speech
