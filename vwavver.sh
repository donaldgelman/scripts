#!/usr/bin/env bash

# Create a given number ($3) of audio clips from a given audio or video file ($1) of a given length ($4). Place the clips in $2.

# Check for required tools
for tool in ffprobe ffmpeg shuf; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: $tool is not installed or not in PATH."
        exit 1
    fi
done

# Function to display usage information
usage() {
    echo "Usage: $0 <audio_or_video_file> <output_directory> <number_of_clips> <clip_length_in_seconds>"
    echo "  audio_or_video_file: Path to the input file"
    echo "  output_directory: Directory to save the clips"
    echo "  number_of_clips: Number of audio clips to create"
    echo "  clip_length_in_seconds: Length of each clip in seconds"
    exit 1
}

# Check if the correct number of arguments is provided
if [ $# -ne 4 ]; then
    usage
fi

vid="$1"
dir="$2"
clips="$3"
length="$4"

# Validate input file
if [ ! -f "$vid" ] || [ ! -r "$vid" ]; then
    echo "Error: File '$vid' does not exist or is not readable."
    exit 1
fi

# Validate number of clips
if ! [[ "$clips" =~ ^[0-9]+$ ]] || [ "$clips" -le 0 ]; then
    echo "Error: Number of clips must be a positive integer."
    exit 1
fi

# Validate clip length
if ! [[ "$length" =~ ^[0-9]+(\.[0-9]+)?$ ]] || [ "$(echo "$length <= 0" | bc -l)" -eq 1 ]; then
    echo "Error: Clip length must be a positive number."
    exit 1
fi

# Get video length (in seconds, with millisecond precision for accuracy)
if ! vlength=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" 2>/dev/null); then
    echo "Error: Failed to retrieve length for '$vid'."
    exit 1
fi

# Validate video length
if [ -z "$vlength" ] || [ "$(echo "$vlength < $length" | bc -l)" -eq 1 ]; then
    echo "Error: The length of the input file is less than or equal to the clip length or invalid."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$dir" || {
    echo "Error: Failed to create or access output directory '$dir'."
    exit 1
}

# Generate audio clips
i=1
while [ "$i" -le "$clips" ]; do
    # Generate random start time with precision
    rand_seconds=$(printf "%.3f" $(echo "$vlength - $length" | bc -l))
    rand_seconds=$(echo "scale=3; $RANDOM / 32767 * $rand_seconds" | bc)
    rand=$(echo "$rand_seconds" | sed 's/\./_/')
    rand2=$(echo "scale=3; $rand_seconds + $length" | bc)

    echo "Generating clip $i of $clips starting at $rand_seconds seconds..."
    if ! ffmpeg -i "$vid" -ac 2 -ss "$rand_seconds" -to "$rand2" "$dir/$rand.wav" 2>/dev/null; then
        echo "Warning: Failed to generate clip at timestamp $rand_seconds seconds, skipping."
    fi
    i=$((i + 1))
done

echo "Done! Generated $clips audio clips in '$dir'."
