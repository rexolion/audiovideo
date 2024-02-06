#!/bin/sh

if [ $# -eq 0 ]; then
  echo "No file provided."
  exit 1
fi

audioFile=$1
audioFileWithoutExtension=$(echo "$audioFile" | sed 's/\.[^.]*$//')

echo "Generating transcription with Whisper AI"

whisper "$audioFile" \
  --language English \
  --model medium \
  --fp16 False \
  --verbose False \
  --word_timestamps True \
  --output_format srt \
  --output_dir .

echo "Please check the spellings and close the editor when you done"

code --wait -n "$audioFileWithoutExtension.srt"

echo "Generating showcqt video with ffmpeg"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -i "$audioFile" \
  -filter_complex "[0:a]showcqt=s=1920x1080,format=yuv420p[v]" \
  -map "[v]" -map 0:a "$audioFileWithoutExtension.mp4"

echo "Adding transcription as subtitles to the video"

ffmpeg \
  -hide_banner \
  -loglevel error \
  -i "$audioFileWithoutExtension.mp4" \
  -vf subtitles="$audioFileWithoutExtension.srt:force_style='FontName=Futura,FontSize=28,Outline=0,Shadow=0,MarginV=40'" \
  "${audioFileWithoutExtension}_for_publish.mp4"

osascript -e 'display notification "Video from audio has been completed" with title "Video ready!"'

echo "Cleaning up"

rm "$audioFile"
rm "$audioFileWithoutExtension.mp4"
rm "$audioFileWithoutExtension.srt"

echo "Success"
