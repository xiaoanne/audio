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

# Start the speech synthesis task
task_id=$(aws polly start-speech-synthesis-task \
  --region ap-southeast-2 \
  --endpoint-url "https://polly.ap-southeast-2.amazonaws.com/" \
  --output-format mp3 \
  --output-s3-bucket-name "${s3_bucket}" \
  --output-s3-key-prefix "${s3_folder}/${chapter}" \
  --voice-id Zhiyu \
  --text "$story_chinese" \
  --query 'SynthesisTask.TaskId' --output text)

echo "Speech synthesis task started with ID: $task_id"

# Wait for the task to complete
aws polly wait speech-synthesis-task-completed --task-id "$task_id"

# Retrieve the latest MP3 file after task completion
latest_mp3=$(aws s3api list-objects --bucket "$s3_bucket" --prefix "${s3_folder}/${chapter}" --query 'Contents | sort_by(@, &LastModified) | [-1].Key' --output text)
echo "The latest MP3 file after task completion is: $latest_mp3"

# Copy the object with the new name
echo "Now copying to chapter mp3 file"
aws s3 cp "s3://${s3_bucket}/${s3_folder}/.mp3" "s3://${s3_bucket}/${s3_folder}/${chapter}.mp3"

# Delete the original object
aws s3 rm "s3://${s3_bucket}/${s3_folder}/.mp3"