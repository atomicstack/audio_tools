#!/bin/bash

set -x
ffmpeg -i "$1" -write_id3v2 1 -id3v2_version 3 -c:v copy "$2"
set +x
