Useful command:
aws polly synthesize-speech --text "从前有一个农夫，他非常急于想要让自己的庄稼茁壮成长。一天，他听说了一个关于“揠苗助长”的故事，觉得这是一个神奇的方法，可以让庄稼更快地生长。于是，他决定试一试。他每天都去田地里，小心翼翼地把刚刚发芽的幼苗拔起一些，希望这样能够刺激它们更快地生长。然而，随着时间的推移，他却发现，这些被他揠苗助长的幼苗变得越来越弱小，甚至有些开始枯萎了。农夫陷入了困惑和焦虑之中。他开始反思自己的行为，意识到自己误解了“揠苗助长”的真正含义。他明白，庄稼需要的是自然的生长过程，而不是被过度干预。他开始放下焦虑，让幼苗按照它们自己的步伐生长。随着时间的推移，幼苗们逐渐变得更加茁壮，成长得很健康。农夫从中领悟到，自然的规律是无法被人为改变的，任何过度的干预都可能适得其反。他学会了尊重自然的力量，不再急于求成，而是耐心地等待着收获的季节。从那以后，农夫不再揠苗助长，而是选择与大自然合作，给予庄稼适当的呵护和关爱。他的庄稼茁壮成长，他也变得更加睿智和深思熟虑。这个故事告诉我们，在生活中，有时候过于急躁和干预，并不一定能够达到预期的效果，而尊重自然的规律和节奏，可能会带来更好的结果。"
 --output-format mp3 --voice-id Zhiyu --sample-rate 16000 output.mp3
aws polly synthesize-speech --text "Hello, this is a test" --output-format mp3 --voice-id Salli --sample-rate 16000 output.mp3 
aws s3 cp output.mp3 s3://lunyu/chengyu/bamiaozhuzhang.mp3 
aws s3 cp output.mp3 s3://lunyu/daodejing/a.mp3 
aws s3api put-object-tagging --bucket lunyu --key chengyu/bamiaozhuzhang.mp3 --tagging 'TagSet=[{Key=scope,Value=c}, {Key=author,Value=anne}]'
aws s3api put-object-tagging --bucket lunyu --key daodejing/a.mp3 --tagging 'TagSet=[{Key=scope,Value=c}, {Key=author,Value=anne}]'

aws s3api list-objects --bucket lunyu

aws translate translate-text --text "你好，这是一个测试" --source-language-code zh --target-language-code en

aws s3 sync s3://everyday-story .

cd /Users/anne/Downloads/ximalaya/古蜀国密码/古蜀国密码
aws s3 sync s3://everyday-story/gushuguomima .
ls 古蜀国密码_5*

#Not working
aws s3api list-objects-v2 --bucket lunyu --query 'Contents[?starts_with(Key, `chengyu/`) && TagSet[?Key==`scope`]]'


