#!/usr/bin/python3

#Lists the files used in an open Audacity project.

import os
import sys
import json

if sys.platform == 'win32':
    #print("pipe-test.py, running on windows")
    TONAME = '\\\\.\\pipe\\ToSrvPipe'
    FROMNAME = '\\\\.\\pipe\\FromSrvPipe'
    EOL = '\r\n\0'
else:
    #print("pipe-test.py, running on linux or mac")
    TONAME = '/tmp/audacity_script_pipe.to.' + str(os.getuid())
    FROMNAME = '/tmp/audacity_script_pipe.from.' + str(os.getuid())
    EOL = '\n'

# Make sure pipes exist
if not os.path.exists(TONAME):
    print("Exiting. Ensure Audacity is running with mod-script-pipe.")
    sys.exit()

if not os.path.exists(FROMNAME):
    print("Exiting. Ensure Audacity is running with mod-script-pipe.")
    sys.exit()

TOFILE = open(TONAME, 'w')
FROMFILE = open(FROMNAME, 'rt')

def send_command(command):
    """Send a single command to Audacity."""
    TOFILE.write(command + EOL)
    TOFILE.flush()

def get_response():
    """Get and return the command response from Audacity."""
    result = ''
    line = ''
    while True:
        result += line
        line = FROMFILE.readline()
        if line == '\n' and len(result) > 0:
            break
    return result

def do_command(command):
    """Send a command and return the response."""
    send_command(command)
    response = get_response()
    #print("Rcvd: <<< \n" + response)
    return response

def list_tracks():
    """Fetch a list of all tracks in the current project."""
    response = do_command('GetInfo: Type=Tracks')
    start_index = response.find('[')  # Find the start of the JSON array
    end_index = response.rfind(']') + 1  # Find the end of the JSON array
    clean_response = response[start_index:end_index]  # Extract the valid JSON part
    try:
        # Parse the JSON response
        tracks = json.loads(clean_response)
        for track in tracks:
            print(track["name"])

    except json.JSONDecodeError:
        print("Failed to decode JSON response.")
        print("Raw response:\n", response)

# Run the list_tracks function to fetch and print track names
list_tracks()

