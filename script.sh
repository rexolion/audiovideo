#!/bin/sh

if [ $# -eq 0 ]; then
  echo "No file provided."
  exit 1
fi

audioFile=$1
audioFileWithoutExtension=$(echo "$audioFile" | sed 's/\.[^.]*$//')

echo "Removing silence from audio"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -i "$audioFile" \
  -af silenceremove=start_periods=1:stop_periods=-1:stop_duration=0.2:start_threshold=-45dB:stop_threshold=-45dB \
  "desilenced_$audioFile"

echo "Normalize volume of audion"

ffmpeg-normalize \
  "desilenced_$audioFile" \
  -c:a aac \
  -o "normalized_$audioFile"

echo "Generating transcription with Whisper AI"

whisper "normalized_$audioFile" \
  --language English \
  --model medium \
  --fp16 False \
  --verbose False \
  --word_timestamps True \
  --output_format srt \
  --output_dir .

plainTextTranscription=$(< "normalized_$audioFileWithoutExtension.srt" grep -E -v "^[0-9]+$|^[0-9]+:[0-9]+:[0-9]+,[0-9]+ --> [0-9]+:[0-9]+:[0-9]+,[0-9]+$" | sed '/^[[:space:]]*$/d' | sed 's/<u>//g; s/<\/u>//g' | awk '!seen[$0]++' | tr -d '\n' | head -100)

echo "Please check the spellings and close the editor when you done"

code --wait -n "normalized_$audioFileWithoutExtension.srt"

echo "Generating showspectrum video with ffmpeg"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -i "normalized_$audioFile" \
  -filter_complex "[0:a]showspectrum=color=fiery:saturation=1:slide=scroll:scale=log:win_func=gauss:overlap=1:s=960x1080,pad=1920:1080[vs]; [0:a]showspectrum=color=fiery:saturation=2:slide=rscroll:scale=log:win_func=gauss:overlap=1:s=960x1080[ss]; [0:a]showwaves=s=1920x540:mode=p2p,inflate[sw]; [vs][ss]overlay=w[out]; [out][sw]overlay=0:(H-h)/2[out]" \
  -map "[out]" \
  -map 0:a -c:v libx264 -preset fast -crf 18 -c:a copy \
  "$audioFileWithoutExtension.mp4"

echo "Adding transcription as subtitles to the video"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -i "$audioFileWithoutExtension.mp4" \
  -vf subtitles="normalized_$audioFileWithoutExtension.srt:force_style='FontName=Futura,FontSize=28,Outline=0,Shadow=0,MarginV=40,Alignment=6'" \
  "${audioFileWithoutExtension}_for_publish.mp4"

echo "——————————————"
echo "10 titles for Youtube video based on this transcription:"
echo ""

echo "$plainTextTranscription" | llm -m mistral-7b-instruct-v0 -s "Give me 10 titles for Youtube video based on this transcription"

echo "——————————————"

echo ""

echo "——————————————"
echo "10 tags for Youtube video based on this transcription:"
echo ""

echo "$plainTextTranscription" | llm -m mistral-7b-instruct-v0 -s "Give me 10 tags for Youtube video based on this transcription"

echo "——————————————"

echo ""

echo "——————————————"
echo "Description for Youtube video based on this transcription:"
echo ""

echo "$plainTextTranscription" | llm -m mistral-7b-instruct-v0 -s "Give me description based on this transcription"

echo "——————————————"

osascript -e 'display notification "Video from audio has been completed" with title "Video ready!"'

echo "Cleaning up"

rm "desilenced_$audioFile"
rm "normalized_$audioFile"
rm "$audioFileWithoutExtension.mp4"

echo "Success"
