#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
W=1080; H=1920; FPS=30
OUT="build/scenes"
mkdir -p "$OUT"

# scene <idx> <image> <dur> : builds a 1080x1920 ken-burns clip with POP styling.
# Text is drawn per-scene below (custom layout each).

mkscene () {
  local idx="$1" img="$2" dur="$3" zexpr="$4" filters="$5"
  local frames=$(( dur * FPS ))
  ffmpeg -y -loop 1 -t "$dur" -i "$img" -filter_complex "
    [0:v]split=2[bg][fg];
    [bg]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},
        boxblur=28:2,eq=saturation=1.45:brightness=0.02,
        format=rgba,colorchannelmixer=aa=1[bgb];
    [fg]scale=${W}-140:${H}-720:force_original_aspect_ratio=decrease,
        eq=saturation=1.25:contrast=1.05[fgs];
    [bgb][fgs]overlay=(W-w)/2:230[base];
    [base]${filters},
    zoompan=z='${zexpr}':d=${frames}:s=${W}x${H}:fps=${FPS}:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',
    format=yuv420p[v]
  " -map "[v]" -r "$FPS" -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p "$OUT/s${idx}.mp4"
}

# Decorative helpers reused via drawbox/drawtext inside $filters string.
PINK="0xFF4D8D"; YEL="0xFFD93D"; CREAM="0xFFF3E6"; BROWN="0x5A3A1E"

# ---- Scene 1: HOOK ----
F1="drawbox=x=0:y=120:w=${W}:h=210:color=${PINK}@0.92:t=fill,\
drawtext=fontfile=${FONT}:text='女性に大人気':fontcolor=white:fontsize=92:x=(w-tw)/2:y=150:\
borderw=6:bordercolor=${BROWN}@0.35,\
drawtext=fontfile=${FONT}:text='＼ 新メニュー登場 ／':fontcolor=${YEL}:fontsize=66:x=(w-tw)/2:y=255:\
borderw=5:bordercolor=${BROWN}@0.4,\
drawbox=x=140:y=1530:w=${W}-280:h=240:color=white@0.93:t=fill,\
drawtext=fontfile=${FONT}:text='今だけのお楽しみ♡':fontcolor=${PINK}:fontsize=70:x=(w-tw)/2:y=1565,\
drawtext=fontfile=${FONT}:text='ヘルシー＆映えるおでん':fontcolor=${BROWN}:fontsize=46:x=(w-tw)/2:y=1665"
mkscene 1 "IMG_9905.jpg" 4 "min(zoom+0.0010,1.18)" "$F1"

# ---- Scene 2: 島豚の温しゃぶサラダ ----
F2="drawbox=x=0:y=160:w=${W}:h=300:color=${PINK}@0.9:t=fill,\
drawtext=fontfile=${FONT}:text='新登場':fontcolor=${YEL}:fontsize=58:x=90:y=185:\
box=1:boxcolor=${BROWN}@0.55:boxborderw=18,\
drawtext=fontfile=${FONT}:text='島豚の温しゃぶサラダ':fontcolor=white:fontsize=84:x=(w-tw)/2:y=300:\
borderw=6:bordercolor=${BROWN}@0.4,\
drawbox=x=120:y=1540:w=${W}-240:h=250:color=${YEL}@0.95:t=fill,\
drawtext=fontfile=${FONT}:text='やわらか島豚＋たっぷり野菜':fontcolor=${BROWN}:fontsize=52:x=(w-tw)/2:y=1575,\
drawtext=fontfile=${FONT}:text='女性に人気のヘルシー一品♡':fontcolor=${PINK}:fontsize=56:x=(w-tw)/2:y=1665"
mkscene 2 "IMG_9908.jpg" 5 "min(zoom+0.0009,1.16)" "$F2"

# ---- Scene 3: トマトスライス ----
F3="drawbox=x=0:y=160:w=${W}:h=300:color=0xE83A5B@0.9:t=fill,\
drawtext=fontfile=${FONT}:text='相性抜群':fontcolor=${YEL}:fontsize=58:x=90:y=185:\
box=1:boxcolor=${BROWN}@0.55:boxborderw=18,\
drawtext=fontfile=${FONT}:text='トマトスライス':fontcolor=white:fontsize=92:x=(w-tw)/2:y=300:\
borderw=6:bordercolor=${BROWN}@0.4,\
drawbox=x=300:y=1500:w=480:h=300:color=white@0.95:t=fill,\
drawtext=fontfile=${FONT}:text='¥350':fontcolor=0xE83A5B:fontsize=130:x=(w-tw)/2:y=1530,\
drawtext=fontfile=${FONT}:text='(税込)':fontcolor=${BROWN}:fontsize=44:x=(w-tw)/2:y=1690"
mkscene 3 "IMG_9915.jpg" 5 "min(zoom+0.0009,1.16)" "$F3"

# ---- Scene 4: 限定・希少性（今行く理由） ----
F4="drawbox=x=0:y=0:w=${W}:h=${H}:color=${BROWN}@0.18:t=fill,\
drawbox=x=80:y=560:w=${W}-160:h=800:color=white@0.9:t=fill,\
drawtext=fontfile=${FONT}:text='＼ 数量限定 ／':fontcolor=0xE83A5B:fontsize=78:x=(w-tw)/2:y=620,\
drawtext=fontfile=${FONT}:text='旬のピークは今だけ':fontcolor=${BROWN}:fontsize=66:x=(w-tw)/2:y=760,\
drawtext=fontfile=${FONT}:text='仕込みは毎朝、職人の手仕事。':fontcolor=${BROWN}:fontsize=46:x=(w-tw)/2:y=900,\
drawtext=fontfile=${FONT}:text='無くなり次第、終了です。':fontcolor=0xE83A5B:fontsize=52:x=(w-tw)/2:y=1010,\
drawtext=fontfile=${FONT}:text='＝ 今、行く理由 ＝':fontcolor=white:fontsize=64:x=(w-tw)/2:y=1170:\
box=1:boxcolor=${PINK}@0.95:boxborderw=24"
mkscene 4 "build/spread2.jpg" 5 "min(zoom+0.0007,1.12)" "$F4"

# ---- Scene 5: CTA 予約 ----
F5="drawbox=x=0:y=140:w=${W}:h=240:color=${PINK}@0.92:t=fill,\
drawtext=fontfile=${FONT}:text='ご予約はお早めに♡':fontcolor=white:fontsize=80:x=(w-tw)/2:y=215:\
borderw=5:bordercolor=${BROWN}@0.4,\
drawbox=x=100:y=1430:w=${W}-200:h=370:color=white@0.95:t=fill,\
drawtext=fontfile=${FONT}:text='プロフィールのリンク／QRから':fontcolor=${BROWN}:fontsize=50:x=(w-tw)/2:y=1470,\
drawtext=fontfile=${FONT}:text='かんたんネット予約':fontcolor=${PINK}:fontsize=72:x=(w-tw)/2:y=1560,\
drawtext=fontfile=${FONT}:text='席数に限りあり・お早めに':fontcolor=0xE83A5B:fontsize=46:x=(w-tw)/2:y=1690"
mkscene 5 "IMG_9902.jpg" 5 "min(zoom+0.0009,1.15)" "$F5"

echo "scenes built:"
ls -la "$OUT"
