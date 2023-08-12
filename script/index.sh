#!/bin/bash

function get_index() {
    local category="A"
    local year=$(date +'%Y')
    local day_of_year=$(date +'%j')
    local index="${category}_${year}_${day_of_year}_$(date +'%H:%M:%S')"
    echo "$index, $title" >> "$csv_key"
    echo "$index"  # Return the index value
}

title="和光同尘"
aws_access_key_id='aa'
aws_secret_access_key='aa'
region_name='ap-southeast-2'
bucket_name='everyday-story'
csv_key='../s3/index.csv'

index_value=$(get_index)  # Call the function and capture the index value

echo "Index value: $index_value"
echo "Title value: $title"
