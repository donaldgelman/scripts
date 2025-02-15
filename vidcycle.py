#!/bin/python3

import os
import random
import subprocess
import csv

def get_video_duration(video_path):
    try:
        result = subprocess.run(['ffprobe', '-v', 'fatal', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', video_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return int(float(result.stdout.split('.')[0]))  # Convert to int to avoid float issues
    except:
        print(f"Could not get duration for {video_path}")
        return 0

def generate_edl(folder, duration, repetitions):
    video_files = [os.path.join(folder, f) for f in os.listdir(folder) if f.lower().endswith(('.mp4', '.webm', '.mkv', '.avi'))]
    random.shuffle(video_files)
    
    edl_content = ["# mpv EDL v0"]
    
    for _ in range(repetitions):
        for video in video_files:
            length = get_video_duration(video)
            if length > duration:
                start = random.randint(0, length - duration)
                
                # Handle filenames with commas or special characters
                byte_length = len(video.encode('utf-8'))
                entry = f'%{byte_length}%{video},start={start},length={duration}'
                edl_content.append(entry)

    with open('/home/donaldgelman/bin/tmp/vidcycle.mpv.edl', 'w') as edl_file:
        edl_file.write('\n'.join(edl_content))

    print(f"EDL file written to: /home/donaldgelman/bin/tmp/vidcycle.mpv.edl")

if __name__ == "__main__":
    folder = input("Enter the video folder path: ")
    duration = int(input("Enter the clip duration in seconds: "))
    repetitions = int(input("Enter the number of repetitions: "))
    
    generate_edl(folder, duration, repetitions)
    
    # Run mpv with the generated EDL file
    subprocess.run(['mpv', '--no-audio', '--loop=yes', '--really-quiet', '/home/donaldgelman/bin/tmp/vidcycle.mpv.edl'])
