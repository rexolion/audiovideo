# Audio Transcription and Video Generation Script

This script facilitates the automated process of generating transcriptions for audio files using the Whisper AI transcription model and creating a video with the transcription as subtitles. The resulting video is suitable for publishing and sharing.

## Prerequisites
- [Whisper AI](https://whisper.ai/) installed and configured
- [ffmpeg](https://ffmpeg.org/) installed and accessible in the system path
- [Visual Studio Code](https://code.visualstudio.com/) installed for manual spell-checking

## Usage
1. Ensure that Whisper AI is properly installed and configured on your system.
2. Place the audio file you want to process in the same directory as this script.
3. Open a terminal and run the script with the following command:

   ```bash
   ./script.sh <your_audio_file>
   ```

   Replace `<your_audio_file>` with the name of the audio file you want to process.

4. The script will transcribe the audio using Whisper AI, open Visual Studio Code for manual spell-checking, generate a video with the transcription as subtitles, and notify you when the process is complete.

## Script Details
- The script checks if an audio file is provided as an argument; if not, it exits with an error message.
- Transcription is generated using Whisper AI with specified parameters (language, model, etc.).
- Visual Studio Code is opened for manual spell-checking of the transcription.
- A video is generated with a CQT (Constant-Q Transform) visualization using ffmpeg.
- The transcription is added as subtitles to the video using ffmpeg.
- A notification is displayed when the video is ready for publishing.
- Temporary files (audio file, intermediate video, and transcription file) are cleaned up after successful completion.

## Note
- Make sure to review and correct the transcription for accuracy before closing the Visual Studio Code editor.
- The final video file with subtitles is named `<audio_file_name>_for_publish.mp4`.
- The script assumes that Whisper AI and ffmpeg are correctly installed and accessible in the system path.

Feel free to customize the script or adjust parameters based on your requirements.
