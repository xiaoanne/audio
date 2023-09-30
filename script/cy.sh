#!/bin/bash

# Common variable declarations
bucket_name='everyday-story'
file_path="./script/story_original.txt"
local_prefix="./script"
break_line=""
sample_rate=24000
title_chinese=$(head -n 1 "$file_path")
title_english=$(sed -n '2p' "$file_path")
story_chinese=$(sed -n '3,$p' "$file_path" | tr -d '[:space:]' | tr -d '\n')
echo "${title_chinese}:" "${story_chinese}" > "${local_prefix}/books/story/chinese_${title_chinese}.txt"
echo "${title_chinese}" >> "${local_prefix}/books/book_chinese.txt"
echo "${story_chinese}" >> "${local_prefix}/books/book_chinese.txt"
echo "${break_line}" >> "${local_prefix}/books/book_chinese.txt"

# declare -a story_types=("chinese_version" "english_version" "french_version")
declare -a book_languages=("english" "french")


# ====================Need to update when adding another language==================
generate_books() {
    local English=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
    local French=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
    local Spanish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code es --query 'TranslatedText' --output text)
    local Arabic=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code ar --query 'TranslatedText' --output text)
    
    
    # Create an array with the story variables
    stories=("English" "French" "Spanish" "Arabic")
    
    for story_var in "${stories[@]}"; do
        # Use variable indirection to get the value of the current story variable
        local current_story="${!story_var}"
        local story_path="${local_prefix}/books/story/${story_var}_${title_chinese}.txt"
        local book_path="${local_prefix}/books/book_${story_var}.txt"
        
        echo "${title_english}:" "${current_story}" > "${story_path}"
        echo  "${title_english}" >> "${book_path}"
        echo  "${current_story}" >> "${book_path}"
        echo  "${break_line}" >> "${book_path}"
    done
}


generate_audio() {
    
}

# Call the function
generate_books

