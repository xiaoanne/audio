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
echo "${title_chinese}:" "${story_chinese}" > "${local_prefix}/books/story/Chinese_${title_chinese}.txt"
echo "${title_chinese}" >> "${local_prefix}/books/whole_book/book_Chinese.txt"
echo "${story_chinese}" >> "${local_prefix}/books/whole_book/book_Chinese.txt"
echo "${break_line}" >> "${local_prefix}/books/whole_book/book_Chinese.txt"
aws polly synthesize-speech --text "投桃报李的故事，${story_chinese}" --output-format mp3 --voice-id Zhiyu --sample-rate "$sample_rate" "${local_prefix}/books/audio/Chinese_${title_chinese}.mp3"

# declare -a story_types=("chinese_version" "english_version" "french_version")
declare -a book_languages=("english" "french")


# ====================Need to update when adding another language==================
# English=""
# French=""
# Spanish=""
# Arabic=""
generate_books() {
    English=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code en --query 'TranslatedText' --output text)
    French=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fr --query 'TranslatedText' --output text)
    Spanish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code es --query 'TranslatedText' --output text)
    Arabic=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code ar --query 'TranslatedText' --output text)
    Hindi=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code hi --query 'TranslatedText' --output text)
    Portuguese=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code pt --query 'TranslatedText' --output text)
    Japanese=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code ja --query 'TranslatedText' --output text)
    German=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code de --query 'TranslatedText' --output text)
    Canteness=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code zh --query 'TranslatedText' --output text)
    Korean=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code ko --query 'TranslatedText' --output text)
    Italian=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code it --query 'TranslatedText' --output text)
    Dutch=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code nl --query 'TranslatedText' --output text)
    Polish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code pl --query 'TranslatedText' --output text)
    Danish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code da --query 'TranslatedText' --output text)
    Finnish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code fi --query 'TranslatedText' --output text)
    Norwegian=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code no --query 'TranslatedText' --output text)
    Swedish=$(aws translate translate-text --text "$story_chinese" --source-language-code zh --target-language-code sv --query 'TranslatedText' --output text)
    
    
    
    # Create an array with the story variables
    stories=("English" "French" "Spanish" "Arabic" "Hindi" "Portuguese" "Japanese" "German" "Canteness" "Korean" "Italian" "Dutch" "Polish" "Danish" "Finnish" "Norwegian" "Swedish")
    
    for story_var in "${stories[@]}"; do
        # Use variable indirection to get the value of the current story variable
        local current_story="${!story_var}"
        local story_path="${local_prefix}/books/story/${story_var}_${title_chinese}.txt"
        local book_path="${local_prefix}/books/whole_book/book_${story_var}.txt"
        
        echo "${title_english}:" "${current_story}" > "${story_path}"
        echo  "${title_english}" >> "${book_path}"
        echo  "${current_story}" >> "${book_path}"
        echo  "${break_line}" >> "${book_path}"
    done
}


generate_audio() {
    local audio_path="${local_prefix}/books/audio/"
    aws polly synthesize-speech --text "The story of ${title_english}, ${English}" --engine neural --output-format mp3 --voice-id Matthew --sample-rate $sample_rate "${audio_path}/English_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${French}" --engine neural --output-format mp3 --voice-id Lea --sample-rate $sample_rate "${audio_path}/French_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Spanish}" --engine neural --output-format mp3 --voice-id Lucia --sample-rate $sample_rate "${audio_path}/Spanish_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Arabic}" --engine neural --output-format mp3 --voice-id Hala --sample-rate $sample_rate "${audio_path}/Arabic_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Hindi}" --engine neural --output-format mp3 --voice-id Kajal --sample-rate $sample_rate "${audio_path}/Hindi_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Portuguese}" --engine neural --output-format mp3 --voice-id Ines --sample-rate $sample_rate "${audio_path}/Portuguese_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Japanese}" --engine neural --output-format mp3 --voice-id Kazuha --sample-rate $sample_rate "${audio_path}/Japanese_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${German}" --engine neural --output-format mp3 --voice-id Vicki --sample-rate $sample_rate "${audio_path}/German_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Canteness}" --engine neural --output-format mp3 --voice-id Hiujin --sample-rate $sample_rate "${audio_path}/Canteness_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Korean}" --engine neural --output-format mp3 --voice-id Seoyeon --sample-rate $sample_rate "${audio_path}/Korean_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Italian}" --engine neural --output-format mp3 --voice-id Bianca --sample-rate $sample_rate "${audio_path}/Italian_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Dutch}" --engine neural --output-format mp3 --voice-id Laura --sample-rate $sample_rate "${audio_path}/Dutch_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Polish}" --engine neural --output-format mp3 --voice-id Ola --sample-rate $sample_rate "${audio_path}/Polish_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Danish}" --engine neural --output-format mp3 --voice-id Sofie --sample-rate $sample_rate "${audio_path}/Danish_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Finnish}" --engine neural --output-format mp3 --voice-id Suvi --sample-rate $sample_rate "${audio_path}/Finnish_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Norwegian}" --engine neural --output-format mp3 --voice-id Ida --sample-rate $sample_rate "${audio_path}/Norwegian_${title_chinese}.mp3"
    aws polly synthesize-speech --text "The story of ${title_english}, ${Swedish}" --engine neural --output-format mp3 --voice-id Elin --sample-rate $sample_rate "${audio_path}/Swedish_${title_chinese}.mp3"

}

upload_files() {
    aws s3 cp "${local_prefix}"/books s3://everyday-story/chengyu --recursive
}

# Call the function
generate_books
generate_audio
upload_files

