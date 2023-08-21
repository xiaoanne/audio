#!/bin/bash

# Common variable declarations
bucket_name='everyday-story'
file_path="./chinese_script/story_original.txt"
local_prefix="./downloads"
s3_folder="古蜀国密码1"
sample_rate=24000
title_chinese=$(head -n 1 "$file_path")
#title_english=$(sed -n '2p' "$file_path")
# ====================Need to update when adding another language==================
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
#story_english=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
#story_french=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
category="古蜀国密码"
year=$(date +'%Y')
day_of_year=$(date +'%j')
task_time=$(date +'%H:%M:%S')
i=184

# ====================Need to update when adding another language==================
# Generate index value
index_value="${category}_${year}_${day_of_year}_${task_time}"
echo "Index value: ${index_value}"
echo "Title value: ${title_chinese}"
echo "Chinese story: ${story_chinese}"

# ====================Need to update when adding another language==================
# Declare the arrays for function of upload_files
languages=("chinese")
declare -a book_languages=("chinese")
declare -a story_types=("chinese_version")

# ====================Need to update when adding another language==================
# Declare the arrays and other variables outside of the function generate_books
titles=("$title_chinese")
stories=("$story_chinese")



# ====================Need to update when adding another language==================
generate_speeches() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate $sample_rate "${local_prefix}/${s3_folder}/${index_value}_古蜀国密码_${title_chinese}.mp3"
#    aws polly synthesize-speech --text "$story_english" --output-format mp3 --voice-id Matthew --sample-rate $sample_rate "${local_prefix}/${s3_folder}/${index_value}_english_version_${title_chinese}.mp3"
#    aws polly synthesize-speech --text "$story_french" --output-format mp3 --voice-id Celine --sample-rate $sample_rate "${local_prefix}/${s3_folder}/${index_value}_french_version_${title_chinese}.mp3"
}
generate_speeches
text=$story_chinese
max_text_length=2500  # Adjust this value based on the maximum allowed text length
chunks=( "${text}" )  # Initialize an array with the full text

# Split the text into chunks
while [ "${#chunks[${#chunks[@]}-1]}" -gt "$max_text_length" ]; do
    chunks+=("${chunks[${#chunks[@]}-1]:$max_text_length}")
    chunks[${#chunks[@]}-2]="${chunks[${#chunks[@]}-2]:0:$max_text_length}"
done

# Process each chunk and synthesize speech
#for chunk in "${chunks[@]}"; do
#    aws polly synthesize-speech --text "$chunk" --output-format mp3 --voice-id Zhiyu --sample-rate $sample_rate "${local_prefix}/${s3_folder}/${index_value}_古蜀国密码_$(date +'%H:%M:%S').mp3"
#    i = i+1
#done

for chunk in "${chunks[@]}"; do
    aws polly synthesize-speech --text "$chunk" --output-format mp3 --voice-id Zhiyu --sample-rate $sample_rate "${local_prefix}/${s3_folder}/古蜀国密码_$i.mp3"
    ((i++))
done


# Upload books, index file, mp3 audio and metadata json files into s3 bucket
upload_files() {
    local local_prefix="$1" # Get the local prefix from the function argument

    echo "Now uploading mp3 files."
    for type in "${story_types[@]}"; do
        echo "Now uploading ${type} mp3 files."
        aws s3 cp "${local_prefix}/${s3_folder}/" "s3://everyday-story/${s3_folder}/" --recursive
    done
}
upload_files "${local_prefix}"