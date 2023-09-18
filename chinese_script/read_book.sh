#!/bin/bash

start_string="第七十五章"
#start_string="禹京坐下去"
end_string="第七十六章"
#end_string="她愤怒得出奇"

input_file="gu.txt"
#input_file="story_original.txt"
output_file="story_original.txt"
#output_file="story_original_63-1.txt"

# Use sed to extract content between start and end strings
sed -n "/$start_string/,/$end_string/p" $input_file > story_original_test.txt

# Remove lines 2 to 5 and the last line using sed
sed '2,5d;$d' "story_original_test.txt" > $output_file

rm story_original_test.txt