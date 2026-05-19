#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
OUT="build/scenes"; DUR=6; FPS=30
PINK="0xFF8FB3"; YEL="0xFFD15E"; RED="0xF06A86"; CREAM="0xFFF4E3"; BROWN="0x6B4A2E"
fade(){ echo "clip((t-$1)/0.5\,0\,1)"; }
slide_y(){ echo "$1-36*(1-clip((t-$2)/0.5\,0\,1))"; }
DOTS="♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡"

# QR scene: STATIC (no zoom) so the code stays sharp & scannable.
# Header band 0..300 | QR card 320..1640 | Footer band 1660..1920
ffmpeg -y -loop 1 -t "$DUR" -i build/qr.png -filter_complex "
  [0:v]split=2[bg][fg];
  [bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=34:2,eq=saturation=0.85:brightness=0.10:contrast=0.95[bgb];
  [fg]scale=1000:1250:force_original_aspect_ratio=decrease,pad=1040:1290:(ow-iw)/2:(oh-ih)/2:white[card];
  [bgb][card]overlay=x=(W-w)/2:y=330[ph];
  [ph]drawbox=x=0:y=0:w=1080:h=300:color=${PINK}:t=fill,
      drawbox=x=0:y=1660:w=1080:h=260:color=${PINK}:t=fill,
      drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${CREAM}@0.55:fontsize=34:x=(w-tw)/2:y=256,
      drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${CREAM}@0.55:fontsize=34:x=(w-tw)/2:y=1700,
      drawtext=fontfile=${FONT}:text='ご予約はこちら♡':fontcolor=white:fontsize=88:x=(w-tw)/2:y='$(slide_y 70 0)':alpha='$(fade 0)':borderw=3:bordercolor=${RED}@0.25,
      drawtext=fontfile=${FONT}:text='＼ QRコードで かんたんネット予約 ／':fontcolor=${YEL}:fontsize=52:x=(w-tw)/2:y=185:alpha='$(fade 0.4)',
      drawtext=fontfile=${FONT}:text='ご来店、お待ちしております♡':fontcolor=white:fontsize=48:x=(w-tw)/2:y=1745:alpha='$(fade 0.5)',
      format=yuv420p[v]
 " -map "[v]" -r "$FPS" -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p "$OUT/s6.mp4"
echo "s6 built"; ls -la "$OUT/s6.mp4"
