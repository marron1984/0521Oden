#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
S="build/scenes"
XF=0.6   # crossfade duration

# durations: s1=4 s2=5 s3=5 s4=5 s5=5
# chain xfade with cumulative offsets (prev_total - XF)
ffmpeg -y \
 -i "$S/s1.mp4" -i "$S/s2.mp4" -i "$S/s3.mp4" -i "$S/s4.mp4" -i "$S/s5.mp4" \
 -filter_complex "
  [0:v][1:v]xfade=transition=fade:duration=${XF}:offset=$(echo "4-$XF"|bc)[a];
  [a][2:v]xfade=transition=fade:duration=${XF}:offset=$(echo "4+5-2*$XF"|bc)[b];
  [b][3:v]xfade=transition=fade:duration=${XF}:offset=$(echo "4+5+5-3*$XF"|bc)[c];
  [c][4:v]xfade=transition=fade:duration=${XF}:offset=$(echo "4+5+5+5-4*$XF"|bc)[v]
 " -map "[v]" \
 -f lavfi -t 30 -i anullsrc=channel_layout=stereo:sample_rate=44100 \
 -map 1:a -shortest \
 -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -movflags +faststart \
 -c:a aac -b:a 128k \
 "reel_島豚の温しゃぶサラダ_トマトスライス.mp4"

echo "done:"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 "reel_島豚の温しゃぶサラダ_トマトスライス.mp4"
