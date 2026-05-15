#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
W=1080; H=1920; FPS=30
OUT="build/scenes"
mkdir -p "$OUT"

# Layout zones (no overlap between photo and text):
#   HEADER : y 0   .. 360   solid color band  -> title
#   PHOTO  : y 380 .. 1470  clean area        -> photo (contained, gentle zoom)
#   FOOTER : y 1490.. 1920  solid color band  -> description / price
PT_Y=380          # photo zone top
PT_H=1090         # photo zone height
PW=$((W-120))     # photo max width (60px side margins)

PINK="0xFF4D8D"; YEL="0xFFD93D"; BROWN="0x5A3A1E"; RED="0xE83A5B"

# mkscene <idx> <image> <dur> <zexpr> <header_band_color> <footer_band_color> <textfilters>
mkscene () {
  local idx="$1" img="$2" dur="$3" zexpr="$4" hcol="$5" fcol="$6" texts="$7"
  local frames=$(( dur * FPS ))
  ffmpeg -y -loop 1 -t "$dur" -i "$img" -filter_complex "
    [0:v]split=2[bg][fg];
    [bg]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},
        boxblur=30:2,eq=saturation=1.2:brightness=-0.05[bgb];
    [fg]scale=${PW}:${PT_H}:force_original_aspect_ratio=decrease,
        eq=saturation=1.2:contrast=1.04,
        zoompan=z='${zexpr}':d=${frames}:s=${PW}x${PT_H}:fps=${FPS}:
          x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fgz];
    [bgb][fgz]overlay=x='(W-w)/2':y='${PT_Y}+(${PT_H}-h)/2'[ph];
    [ph]drawbox=x=0:y=0:w=${W}:h=360:color=${hcol}:t=fill,
        drawbox=x=0:y=1490:w=${W}:h=430:color=${fcol}:t=fill,
        ${texts},
    format=yuv420p[v]
  " -map "[v]" -r "$FPS" -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p "$OUT/s${idx}.mp4"
}

# ---- Scene 1: HOOK ----
T1="drawtext=fontfile=${FONT}:text='女性に大人気':fontcolor=white:fontsize=96:x=(w-tw)/2:y=70:\
borderw=4:bordercolor=${BROWN}@0.3,\
drawtext=fontfile=${FONT}:text='＼ 新メニュー登場 ／':fontcolor=${YEL}:fontsize=64:x=(w-tw)/2:y=215,\
drawtext=fontfile=${FONT}:text='今だけのお楽しみ♡':fontcolor=white:fontsize=78:x=(w-tw)/2:y=1560,\
drawtext=fontfile=${FONT}:text='ヘルシー＆映えるおでん':fontcolor=${YEL}:fontsize=52:x=(w-tw)/2:y=1690"
mkscene 1 "IMG_9905.jpg" 4 "min(zoom+0.0010,1.16)" "${PINK}@1.0" "${PINK}@1.0" "$T1"

# ---- Scene 2: 島豚の温しゃぶサラダ ----
T2="drawtext=fontfile=${FONT}:text='新登場':fontcolor=${PINK}:fontsize=52:x=70:y=70:\
box=1:boxcolor=white:boxborderw=16,\
drawtext=fontfile=${FONT}:text='島豚の温しゃぶサラダ':fontcolor=white:fontsize=80:x=(w-tw)/2:y=200,\
drawtext=fontfile=${FONT}:text='やわらか島豚＋たっぷり野菜':fontcolor=${BROWN}:fontsize=54:x=(w-tw)/2:y=1560,\
drawtext=fontfile=${FONT}:text='女性に人気のヘルシー一品♡':fontcolor=${PINK}:fontsize=58:x=(w-tw)/2:y=1680"
mkscene 2 "IMG_9908.jpg" 5 "min(zoom+0.0009,1.14)" "${PINK}@1.0" "${YEL}@1.0" "$T2"

# ---- Scene 3: トマトスライス ----
T3="drawtext=fontfile=${FONT}:text='相性抜群':fontcolor=${RED}:fontsize=52:x=70:y=70:\
box=1:boxcolor=white:boxborderw=16,\
drawtext=fontfile=${FONT}:text='トマトスライス':fontcolor=white:fontsize=92:x=(w-tw)/2:y=190,\
drawtext=fontfile=${FONT}:text='¥350':fontcolor=white:fontsize=120:x=(w-tw)/2:y=1540,\
drawtext=fontfile=${FONT}:text='(税込)':fontcolor=white:fontsize=44:x=(w-tw)/2:y=1700"
mkscene 3 "IMG_9915.jpg" 5 "min(zoom+0.0009,1.14)" "${RED}@1.0" "${RED}@1.0" "$T3"

# ---- Scene 4: 限定・希少性 (今行く理由) ----
T4="drawtext=fontfile=${FONT}:text='＼ 数量限定 ／':fontcolor=${YEL}:fontsize=76:x=(w-tw)/2:y=120,\
drawtext=fontfile=${FONT}:text='旬のピークは今だけ':fontcolor=white:fontsize=64:x=(w-tw)/2:y=240,\
drawtext=fontfile=${FONT}:text='仕込みは毎朝、職人の手仕事。':fontcolor=white:fontsize=46:x=(w-tw)/2:y=1530,\
drawtext=fontfile=${FONT}:text='無くなり次第、終了です。':fontcolor=${YEL}:fontsize=52:x=(w-tw)/2:y=1620,\
drawtext=fontfile=${FONT}:text='＝ 今、行く理由 ＝':fontcolor=${RED}:fontsize=58:x=(w-tw)/2:y=1730:\
box=1:boxcolor=white:boxborderw=14"
mkscene 4 "build/spread2.jpg" 5 "min(zoom+0.0007,1.10)" "${BROWN}@1.0" "${BROWN}@1.0" "$T4"

# ---- Scene 5: CTA 予約 ----
T5="drawtext=fontfile=${FONT}:text='ご予約はお早めに♡':fontcolor=white:fontsize=82:x=(w-tw)/2:y=130,\
drawtext=fontfile=${FONT}:text='席数に限りあり':fontcolor=${YEL}:fontsize=50:x=(w-tw)/2:y=255,\
drawtext=fontfile=${FONT}:text='プロフィールのリンク／QRから':fontcolor=white:fontsize=48:x=(w-tw)/2:y=1540,\
drawtext=fontfile=${FONT}:text='かんたんネット予約':fontcolor=${YEL}:fontsize=72:x=(w-tw)/2:y=1640"
mkscene 5 "IMG_9902.jpg" 5 "min(zoom+0.0009,1.13)" "${PINK}@1.0" "${PINK}@1.0" "$T5"

echo "scenes built:"
ls -la "$OUT"
