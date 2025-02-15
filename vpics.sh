#!/usr/bin/env bash

# Extract a given number ($2) of random frames from a video file ($1) and save them as JPEG images with millisecond precision in timestamp names.
# Usage: ./script.sh <video_file> <num_images> [output_dir]

# Function to display usage information
usage() {
    echo "Usage: $0 <video_file> <num_images> [output_dir]"
    echo "  video_file: Path to the input video file"
    echo "  num_images: Number of random frames to extract"
    echo "  output_dir: Optional output directory (default: current directory)"
    exit 1
}

# Check for required tools
for tool in ffprobe ffmpeg shuf; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: $tool is not installed or not in PATH."
        exit 1
    fi
done

# Check if the correct number of arguments is provided
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
fi

vid="$1"
pics="$2"
output_dir="${3:-.}"

# Validate input video file
if [ ! -f "$vid" ] || [ ! -r "$vid" ]; then
    echo "Error: Video file '$vid' does not exist or is not readable."
    exit 1
fi

# Validate number of images
if ! [[ "$pics" =~ ^[0-9]+$ ]] || [ "$pics" -le 0 ]; then
    echo "Error: Number of images must be a positive integer."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$output_dir" || {
    echo "Error: Failed to create output directory '$output_dir'."
    exit 1
}

# Get video length (in seconds, with millisecond precision)
if ! vlength=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" 2>/dev/null); then
    echo "Error: Failed to retrieve video length for '$vid'."
    exit 1
fi

# Validate video length
if [ -z "$vlength" ] || [ "$(echo "$vlength < 0.001" | bc -l)" -eq 1 ]; then
    echo "Error: Invalid or zero video length for '$vid'."
    exit 1
fi

# Generate random frames with millisecond precision in names
i=1
while [ "$i" -le "$pics" ]; do
    # Generate a random number with millisecond precision
    rand_seconds=$(printf "%.3f" $(echo "$vlength * $RANDOM / 32767" | bc -l))
    # Ensure we don't exceed video duration
    if (( $(echo "$rand_seconds > $vlength" | bc -l) )); then
        rand_seconds=$(echo "$vlength - 0.001" | bc)
    fi
    # Format timestamp for filename
    timestamp=$(echo "$rand_seconds" | sed 's/\./_/')
    output_file="$output_dir/$timestamp.jpg"
    echo "Generating frame $i of $pics at timestamp $rand_seconds seconds..."
    if ! ffmpeg -y -ss "$rand_seconds" -i "$vid" -vframes 1 -q:v 2 "$output_file" 2>/dev/null; then
        echo "Warning: Failed to generate frame at timestamp $rand_seconds seconds, skipping."
    fi
    i=$((i + 1))
done

echo "Done! Generated $pics frames in '$output_dir'."
