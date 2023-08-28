#!/bin/bash

start_string="第四十四章"
end_string="第四十五章"

input_file="gu.txt"
output_file="story_original.txt"

# Use sed to extract content between start and end strings
sed -n "/$start_string/,/$end_string/p" $input_file > story_original_test.txt

# Remove lines 2 to 5 and the last line using sed
sed '2,5d;$d' "story_original_test.txt" > $output_file

rm story_original_test.txt