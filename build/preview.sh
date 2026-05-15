#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
MASK="build/mask_photo.png"
PINK="0xFF8FB3"; YEL="0xFFD15E"; RED="0xF06A86"; CREAM="0xFFF4E3"; BROWN="0x6B4A2E"
fade(){ echo "clip((t-$1)/0.5\,0\,1)"; }
slide_y(){ echo "$1-36*(1-clip((t-$2)/0.5\,0\,1))"; }
DOTS="♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡"
T1="drawtext=fontfile=${FONT}:text='女性に大人気♡':fontcolor=white:fontsize=92:x=(w-tw)/2:y='$(slide_y 75 0)':alpha='$(fade 0)':borderw=4:bordercolor=${RED}@0.3,\
drawtext=fontfile=${FONT}:text='＼ 新メニュー登場 ／':fontcolor=${YEL}:fontsize=62:x=(w-tw)/2:y=220:alpha='$(fade 0.4)',\
drawtext=fontfile=${FONT}:text='今だけのお楽しみ':fontcolor=white:fontsize=76:x=(w-tw)/2:y='$(slide_y 1565 0.2)':alpha='$(fade 0.2)',\
drawtext=fontfile=${FONT}:text='ヘルシー＆映えるおでん':fontcolor=${YEL}:fontsize=50:x=(w-tw)/2:y=1700:alpha='$(fade 0.6)'"
ffmpeg -y -loop 1 -t 3 -i IMG_9905.jpg -loop 1 -t 3 -i "$MASK" -filter_complex "
  [0:v]split=2[bg][fg];
  [bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=34:2,eq=saturation=0.85:brightness=0.10:contrast=0.95[bgb];
  [fg]scale=904:1034:force_original_aspect_ratio=decrease,pad=960:1090:(ow-iw)/2:(oh-ih)/2:white,eq=saturation=1.18:contrast=1.04,zoompan=z='min(zoom+0.001,1.12)':d=90:s=960x1090:fps=30:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fgz];
  [1:v]format=gray[mk];
  [fgz][mk]alphamerge[card];
  [bgb][card]overlay=x=(W-w)/2:y=380[ph];
  [ph]drawbox=x=0:y=0:w=1080:h=360:color=${PINK}:t=fill,
      drawbox=x=0:y=1490:w=1080:h=430:color=${PINK}:t=fill,
      drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${CREAM}@0.55:fontsize=34:x=(w-tw)/2:y=312,
      drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${CREAM}@0.55:fontsize=34:x=(w-tw)/2:y=1540,
      ${T1},
      format=yuv420p[v]
 " -map "[v]" -ss 2 -frames:v 1 build/preview1.png
echo OK
