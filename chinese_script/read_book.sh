#!/bin/bash

start_string="第四十八章"
#start_string="对付落头族其实非常简单"
#end_string="第四十九章"
end_string="你就是鱼凫王"

#input_file="gu.txt"
input_file="story_original.txt"
#output_file="story_original.txt"
output_file="story_original_48-1.txt"

# Use sed to extract content between start and end strings
sed -n "/$start_string/,/$end_string/p" $input_file > story_original_test.txt

# Remove lines 2 to 5 and the last line using sed
sed '2,5d;$d' "story_original_test.txt" > $output_file

rm story_original_test.txt