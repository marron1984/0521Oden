#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
W=1080; H=1920; FPS=30
OUT="build/scenes"
MASK="build/mask_photo.png"   # 960x1090 rounded alpha mask
mkdir -p "$OUT"

# Layout: HEADER band 0..360 | PHOTO card 380..1470 | FOOTER band 1490..1920
PT_Y=380; PT_H=1090; PW=960

# Pastel POP palette
PINK="0xFF8FB3"; MINT="0x7FD9C7"; CREAM="0xFFF4E3"
YEL="0xFFD15E"; BROWN="0x6B4A2E"; RED="0xF06A86"

# fade-in alpha expr (delay d, fade 0.5s) ; slide-in y (target Y, rise 36px)
fade () { echo "clip((t-$1)/0.5\,0\,1)"; }     # $1 = delay sec
slide_y () { echo "$1-36*(1-clip((t-$2)/0.5\,0\,1))"; }  # $1=Y $2=delay

# mkscene <idx> <image> <dur> <zexpr> <hcol> <fcol> <accentcol> <texts>
mkscene () {
  local idx="$1" img="$2" dur="$3" zexpr="$4" hcol="$5" fcol="$6" acc="$7" texts="$8"
  local frames=$(( dur * FPS ))
  local DOTS="♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡   ♡"
  ffmpeg -y -loop 1 -t "$dur" -i "$img" -loop 1 -t "$dur" -i "$MASK" -filter_complex "
    [0:v]split=2[bg][fg];
    [bg]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},
        boxblur=34:2,eq=saturation=0.85:brightness=0.10:contrast=0.95[bgb];
    [fg]scale=904:1034:force_original_aspect_ratio=decrease,
        pad=${PW}:${PT_H}:(ow-iw)/2:(oh-ih)/2:white,
        eq=saturation=1.18:contrast=1.04,
        zoompan=z='${zexpr}':d=${frames}:s=${PW}x${PT_H}:fps=${FPS}:
          x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fgz];
    [1:v]format=gray[mk];
    [fgz][mk]alphamerge[card];
    [bgb][card]overlay=x=(W-w)/2:y=${PT_Y}[ph];
    [ph]drawbox=x=0:y=0:w=${W}:h=360:color=${hcol}:t=fill,
        drawbox=x=0:y=1490:w=${W}:h=430:color=${fcol}:t=fill,
        drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${acc}@0.55:fontsize=34:x=(w-tw)/2:y=312,
        drawtext=fontfile=${FONT}:text='${DOTS}':fontcolor=${acc}@0.55:fontsize=34:x=(w-tw)/2:y=1540,
        ${texts},
        format=yuv420p[v]
  " -map "[v]" -r "$FPS" -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p "$OUT/s${idx}.mp4"
}

# ---- Scene 1: HOOK ----
T1="drawtext=fontfile=${FONT}:text='女性に大人気♡':fontcolor=white:fontsize=92:x=(w-tw)/2:y='$(slide_y 75 0)':alpha='$(fade 0)':borderw=4:bordercolor=${RED}@0.3,\
drawtext=fontfile=${FONT}:text='＼ 新メニュー登場 ／':fontcolor=${YEL}:fontsize=62:x=(w-tw)/2:y=220:alpha='$(fade 0.4)',\
drawtext=fontfile=${FONT}:text='新しいおいしさ、登場♡':fontcolor=white:fontsize=68:x=(w-tw)/2:y='$(slide_y 1560 0.2)':alpha='$(fade 0.2)',\
drawtext=fontfile=${FONT}:text='ヘルシー＆映えるおでん':fontcolor=${YEL}:fontsize=50:x=(w-tw)/2:y=1700:alpha='$(fade 0.6)'"
mkscene 1 "build/spread1.jpg" 4 "min(zoom+0.0010,1.12)" "${PINK}" "${PINK}" "${CREAM}" "$T1"

# ---- Scene 2: 島豚の温しゃぶサラダ ----
T2="drawtext=fontfile=${FONT}:text='♡ 新登場 ♡':fontcolor=${PINK}:fontsize=50:x=70:y=70:box=1:boxcolor=white:boxborderw=18:alpha='$(fade 0)',\
drawtext=fontfile=${FONT}:text='島豚の温しゃぶサラダ':fontcolor=white:fontsize=78:x=(w-tw)/2:y='$(slide_y 200 0.25)':alpha='$(fade 0.25)':borderw=3:bordercolor=${RED}@0.25,\
drawtext=fontfile=${FONT}:text='やわらか島豚＋たっぷり野菜':fontcolor=${BROWN}:fontsize=52:x=(w-tw)/2:y=1565:alpha='$(fade 0.3)',\
drawtext=fontfile=${FONT}:text='女性に人気のヘルシーな一品♡':fontcolor=${RED}:fontsize=54:x=(w-tw)/2:y='$(slide_y 1685 0.55)':alpha='$(fade 0.55)'"
mkscene 2 "IMG_9908.jpg" 5 "min(zoom+0.0009,1.11)" "${PINK}" "${MINT}" "${CREAM}" "$T2"

# ---- Scene 3: トマトスライス ----
T3="drawtext=fontfile=${FONT}:text='♡ 栄養満点 ♡':fontcolor=${RED}:fontsize=50:x=70:y=70:box=1:boxcolor=white:boxborderw=18:alpha='$(fade 0)',\
drawtext=fontfile=${FONT}:text='トマトスライス':fontcolor=white:fontsize=90:x=(w-tw)/2:y='$(slide_y 190 0.25)':alpha='$(fade 0.25)':borderw=3:bordercolor=${BROWN}@0.25,\
drawtext=fontfile=${FONT}:text='さっぱり美味しい♡':fontcolor=white:fontsize=78:x=(w-tw)/2:y='$(slide_y 1545 0.3)':alpha='$(fade 0.3)',\
drawtext=fontfile=${FONT}:text='箸休めにもぴったり':fontcolor=white:fontsize=46:x=(w-tw)/2:y=1700:alpha='$(fade 0.6)'"
mkscene 3 "IMG_9915.jpg" 5 "min(zoom+0.0009,1.11)" "${RED}" "${RED}" "${CREAM}" "$T3"

# ---- Scene 4: 限定・希少性 (今行く理由) ----
T4="drawtext=fontfile=${FONT}:text='＼ 新作続々 ／':fontcolor=${YEL}:fontsize=74:x=(w-tw)/2:y='$(slide_y 115 0)':alpha='$(fade 0)',\
drawtext=fontfile=${FONT}:text='旬モノも あります':fontcolor=white:fontsize=62:x=(w-tw)/2:y=240:alpha='$(fade 0.35)',\
drawtext=fontfile=${FONT}:text='仕込みは毎朝、職人の手仕事。':fontcolor=white:fontsize=44:x=(w-tw)/2:y=1530:alpha='$(fade 0.25)',\
drawtext=fontfile=${FONT}:text='無くなり次第、終了です。':fontcolor=${YEL}:fontsize=50:x=(w-tw)/2:y=1615:alpha='$(fade 0.5)',\
drawtext=fontfile=${FONT}:text='＝ 今、行く理由 ＝':fontcolor=${RED}:fontsize=56:x=(w-tw)/2:y='$(slide_y 1720 0.75)':alpha='$(fade 0.75)':box=1:boxcolor=white:boxborderw=14"
mkscene 4 "build/spread2.jpg" 5 "min(zoom+0.0007,1.08)" "${BROWN}" "${BROWN}" "${YEL}" "$T4"

# ---- Scene 5: CTA 予約 ----
T5="drawtext=fontfile=${FONT}:text='ご予約はお早めに♡':fontcolor=white:fontsize=80:x=(w-tw)/2:y='$(slide_y 125 0)':alpha='$(fade 0)':borderw=3:bordercolor=${RED}@0.25,\
drawtext=fontfile=${FONT}:text='席数に限りあり':fontcolor=${YEL}:fontsize=48:x=(w-tw)/2:y=255:alpha='$(fade 0.4)',\
drawtext=fontfile=${FONT}:text='プロフィールのリンク／QRから':fontcolor=white:fontsize=46:x=(w-tw)/2:y=1535:alpha='$(fade 0.3)',\
drawtext=fontfile=${FONT}:text='かんたんネット予約':fontcolor=${YEL}:fontsize=70:x=(w-tw)/2:y='$(slide_y 1640 0.55)':alpha='$(fade 0.55)'"
mkscene 5 "IMG_9902.jpg" 5 "min(zoom+0.0009,1.11)" "${PINK}" "${PINK}" "${CREAM}" "$T5"

echo "scenes built:"
ls -la "$OUT"
