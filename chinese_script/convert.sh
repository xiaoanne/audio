#!/bin/bash


# Common variable declarations
file_path="./chinese_script/story_original_49-9.txt"
chapter_number="49-9"
local_prefix="./downloads"
s3_bucket="everyday-story"
s3_folder="gushuguomima"
sample_rate=24000
title_chinese=$(head -n 1 "$file_path")
story_chinese=$(sed -n '2,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
category="古蜀国密码"
year=$(date +'%Y')
day_of_year=$(date +'%j')
task_time=$(date +'%H:%M:%S')
chapter_prefix="gushuguomima_chapter"
chapter="${chapter_prefix}${chapter_number}"
new_chapter_name="${category}_第${chapter_number}章"


# Generate index value
index_value="${category}_${year}_${day_of_year}_${task_time}"
echo "Index value: ${index_value}"
echo "Title value: ${title_chinese}"
echo "Chinese story: ${story_chinese}"



generate_speeches() {
    echo "Generating story speeches."
    aws polly synthesize-speech --text "$story_chinese" --output-format mp3 --voice-id Zhiyu --sample-rate $sample_rate "${local_prefix}/${s3_folder}/${index_value}_古蜀国密码_${title_chinese}.mp3"
}


aws polly start-speech-synthesis-task \
  --region ap-southeast-2 \
  --endpoint-url "https://polly.ap-southeast-2.amazonaws.com/" \
  --output-format mp3 \
  --output-s3-bucket-name everyday-story \
  --output-s3-key-prefix ${s3_folder}/${chapter} \
  --voice-id Zhiyu \
  --text "$story_chinese"

sleep 120

# Get the list of objects in the specified folder, sorted by last modified time
latest_object=$(aws s3api list-objects-v2 \
  --bucket "$s3_bucket" \
  --prefix "$s3_folder" \
  --query "sort_by(Contents, &LastModified) | [-1].Key" \
  --output text
)

echo "The latest object in the $s3_folder folder is: $latest_object"

# Copy the object with the new name
aws s3 cp "s3://${s3_bucket}/${latest_object}" "s3://${s3_bucket}/${s3_folder}/${new_chapter_name}.mp3"

# Delete the original object
sleep 60
aws s3 rm "s3://${s3_bucket}/${latest_object}"