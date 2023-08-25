#!/bin/bash

# Common variable declarations
file_path="./chinese_script/story_original.txt"
s3_bucket="everyday-story"
s3_folder="gushuguomima"
sample_rate=24000
title_chinese=$(head -n 1 "$file_path")
# ====================Need to update when adding another language==================
story_chinese=$(sed -n '2,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
chapter=42

aws polly start-speech-synthesis-task \
  --region ap-southeast-2 \
  --endpoint-url "https://polly.ap-southeast-2.amazonaws.com/" \
  --output-format mp3 \
  --output-s3-bucket-name everyday-story \
  --output-s3-key-prefix ${s3_folder} \
  --voice-id Zhiyu \
  --text "$story_chinese"

# Get the list of objects in the specified folder, sorted by last modified time
latest_object=$(aws s3api list-objects --bucket ${s3_bucket} --prefix ${s3_folder}/ --query 'Contents | sort_by(@, &LastModified) | [-1].Key' --output text)
echo "Latest object name: $latest_object"


# Copy the object with the new name
aws s3 cp "s3://${s3_bucket}/${latest_object}" "s3://${s3_bucket}/${s3_folder}/${chapter}.mp3"

# Delete the original object
#aws s3 rm "s3://${s3_bucket}/${latest_object}"