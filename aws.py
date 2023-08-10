import boto3

# Set up your AWS credentials (replace with your own credentials)
aws_access_key_id = 'zzz'
aws_secret_access_key = 'zzz'
region_name = 'us-east-1'  # Replace with your preferred AWS region


def list_s3_buckets(aws_access_key_id, aws_secret_access_key, region_name):
    # Create an S3 client
    s3 = boto3.client('s3', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key,
                      region_name=region_name)

    # List all S3 buckets
    response = s3.list_buckets()

    # Print the bucket names
    print("S3 Buckets:")
    for bucket in response['Buckets']:
        print(bucket['Name'])


import boto3


def translate_text(aws_access_key_id, aws_secret_access_key, region, text_to_translate, source_language,
                   target_language):
    # Initialize the Translate client
    translate = boto3.client('translate', aws_access_key_id=aws_access_key_id,
                             aws_secret_access_key=aws_secret_access_key, region_name=region)

    # Translate text
    response = translate.translate_text(Text=text_to_translate, SourceLanguageCode=source_language,
                                        TargetLanguageCode=target_language)

    # Print the translated text
    print("Original Text:", text_to_translate)
    print("Translated Text:", response['TranslatedText'])
    translated_text = response['TranslatedText']
    return translated_text


def text_to_speech(aws_access_key_id, aws_secret_access_key, region, text_to_convert, output_format, voice_id):
    # Initialize the Polly client
    polly = boto3.client('polly', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key,
                         region_name=region_name)

    # Convert text to speech
    response = polly.synthesize_speech(Text=text_to_convert, OutputFormat=output_format, VoiceId=voice_id)

    # Save the audio stream to a file
    with open('output.mp3', 'wb') as file:
        file.write(response['AudioStream'].read())


# Text to translate
text_to_translate = "从前有一个宁静的山村，村中有一位名叫李明的年轻人，他一直以“和光同尘”为人生信条。李明生活简单，但他的善良和智慧却在村中传颂。"
source_language = 'zh'
english_target_language = 'en'

# Call the function
list_s3_buckets(aws_access_key_id, aws_secret_access_key, region_name)
translate_text(aws_access_key_id, aws_secret_access_key, region_name, text_to_translate, source_language,
               english_target_language)

# Text to convert to speech
text_to_convert = translate_text(aws_access_key_id, aws_secret_access_key, region_name, text_to_translate, source_language,
               english_target_language)
output_format = 'mp3'
# Voice ID (options: 'Joanna', 'Matthew', 'Salli', etc.)
voice_id = 'Joanna'

text_to_speech(aws_access_key_id, aws_secret_access_key, region_name, text_to_convert, output_format, voice_id)
