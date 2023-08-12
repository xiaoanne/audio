#!/bin/bash

prefix="/home/runner/work/audio/audio/s3"

upload_files() {
    aws s3 cp $prefix/index.csv s3://everyday-story/index.csv
    aws s3 cp $prefix/story/${index_value}_chinese.mp3 s3://everyday-story/story/${index_value}_chinese.mp3
    aws s3 cp $prefix/story/${index_value}_english.mp3 s3://everyday-story/story/${index_value}_english.mp3
    aws s3 cp $prefix/story/${index_value}_french.mp3 s3://everyday-story/story/${index_value}_french.mp3
    aws s3api put-object-tagging --bucket $bucket_name --key story/"$index_value"_chinese.mp3 --tagging 'TagSet=[{Key=language,Value=chinese}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/"$index_value"_english.mp3 --tagging 'TagSet=[{Key=language,Value=english}, {Key=scope,Value=成语}]'
    aws s3api put-object-tagging --bucket $bucket_name --key story/"$index_value"_french.mp3 --tagging 'TagSet=[{Key=language,Value=french}, {Key=scope,Value=成语}]'
}

upload_files