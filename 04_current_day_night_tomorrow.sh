# 現在、日中、夜間、明日のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 表示する要素（0 表示しない、1 表示する）
FLG_C=0  # 現在
FLG_D=1  # 日中
FLG_N=1  # 夜間
FLG_T=1  # 明日
# 現在で表示する内容（0 表示しない、1 表示する）
F_TEMP_C=1  # 温度・天気
F_HUM=1     # 湿度
F_PRES=1    # 気圧
F_CC=0      # 雲量
F_UV_C=0    # 紫外線量
# 日中・夜間・明日で表示する内容（0 表示しない、1 表示する）
F_TEMP_E=1  # 温度・天気
F_PROB=1    # 降水確率
F_PRECIP=1  # 降水量
F_SNOW=0    # 積雪量
F_UV=0      # 紫外線量
# 各段の間の改行数
NLF=0
# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト、二桁目が4で背景の色指定）
COLOR_CP="37;40"
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# データ整理用関数
pickup_data_0() { echo "$1" | awk /"$2"/,/"$3"/ | grep -A1 -e '<p>' -e "$2" | grep -v -e '<p>' -e "$2" | perl -pe 's/--\n//g' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'; }
pickup_data_1() { echo "$1" | awk /"$2"/,/"$3"/ | grep -A1 '<p>' | grep -v '<p>' | perl -pe 's/--\n//g' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'; }
pickup_data_2() { echo "$1" | grep -A1 $2 | grep -v $2 | perl -pe 's/--\n//g'; }

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA="$(curl -A "$USER_AGENT" --silent $WEATHER_URL)"
WEATHER_TODAY=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
WEATHER_TOMORROW=$(curl -A "$USER_AGENT" --silent "${WEATHER_URL/weather-forecast/daily-weather-forecast}?day=2")
DATA_NOW="$(echo "$WEATHER_DATA" | awk '/glacier-ad top content-module/,/connatix/' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')"
DATA_TODAY=$(pickup_data_0 "$WEATHER_TODAY" '<div class="details-card card panel details">' '<div class="quarter-day-links">')
N_T_N=$(echo "$DATA_TODAY" | grep -n '<div class="list">' | cut -f 1 -d ":" | sed -n 2p)
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(pickup_data_1 "$WEATHER_TODAY" '<div class="details-card card panel">' '<\/div>'))
DATA_TODAY_DAY=($(echo "$DATA_TODAY" | sed -n 1,"$N_T_N"p | grep -v '<div class="list">'))
DATA_TODAY_NIT=($(echo "$DATA_TODAY" | sed 1,"$N_T_N"d))
DATA_TOMORROW=($(pickup_data_1 "$WEATHER_TOMORROW" '<div class="details-card card panel details">' '<div class="quarter-day-links">' | sed -n 1,9p))
IFS="$_IFS"

# 各データ取得
_IFS="$IFS";IFS=$'\n'
TITLE=($(pickup_data_2 "$WEATHER_TODAY" 'module-header title' |  tr -d '\t'  | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';))
TITLE_TOMORROW=$(echo "$WEATHER_DATA" | grep -A2 '?day=2' | grep -A1 'card-header' | grep -v 'card-header' | sed -e 's/<[^>]*>//g' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';)
TEMP_HI=($(echo "$WEATHER_TODAY" | grep -A2 '<div class="temperatures">' | grep 'span class' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';))
TEMP_C=$(echo "$DATA_NOW" | grep -m1 '<div class="temp">' | sed -e 's/<[^>]*>//g' |  tr -d '\t')
TEMP_T=($(echo "$WEATHER_TOMORROW" | grep -A2 '<div class="temperatures">' | grep 'span class' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';))
PHRASE_C=$(echo "$DATA_NOW" | grep '<span class="phrase">' | sed -e 's/<[^>]*>//g' |  tr -d '\t')
PHRASE_T=$(echo "$WEATHER_TOMORROW" | grep -m1 '<div class="phrase">' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';)
PHRASE=($(echo "$WEATHER_TODAY" | grep '<div class="phrase">' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }';))
ICON_NO=($(printf "%02d\n" $(echo "$WEATHER_TODAY" | grep 'class="weather-icon icon"'  | awk -F'weathericons/' '{print $2}' | cut -f 1 -d ".")))
ICON_CUR=$(printf "%02d" $(echo "$DATA_CUR" | grep 'class="weather-icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
ICON_T=$(printf "%02d" $(echo "$WEATHER_TOMORROW" |  grep -m1 'class="weather-icon icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
IFS="$_IFS"

#  現在、日中、夜間、明日の天気を表示して天気アイコンを取得し保存
if [ $FLG_C -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[0]}"\033[0m"
  [ $F_TEMP_C -eq 1 ] && printf "%-5s \t%s\n" ${TEMP_HI[0]} "${PHRASE[0]}"
  [ $F_HUM -eq 1 ] && echo ${DATA_CUR[3]}
  [ $F_PRES -eq 1 ] && echo ${DATA_CUR[5]}
  [ $F_CC -eq 1 ] && echo ${DATA_CUR[6]}
  [ $F_UV_C -eq 1 ] && echo ${DATA_CUR[0]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_CUR"-l.png" | xargs curl --silent -o /tmp/weather_current.png
  fi
fi
if [ $FLG_D -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[1]}"\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s \t%s\n" ${TEMP_HI[1]} "${PHRASE[1]}"
  [ $F_PROB -eq 1 ] && echo ${DATA_TODAY_DAY[3]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TODAY_DAY[5]}" \t" | tr -d '\n'
  [ $F_SNOW -eq 1 ] && echo ${DATA_TODAY_DAY[7]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo ${DATA_TODAY_DAY[0]}" \t" | tr -d '\n'
  echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[1]}"-l.png" | xargs curl --silent -o /tmp/weather_today.png
  fi
fi
if [ $FLG_N -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[2]}"\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s  \t%s\n" ${TEMP_HI[2]} "${PHRASE[2]}"
  [ $F_PROB -eq 1 ] && echo ${DATA_TODAY_NIT[2]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TODAY_NIT[4]}" \t" | tr -d '\n'
  [ $F_SNOW -eq 1 ] && echo ${DATA_TODAY_NIT[6]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo | tr -d '\n'
  echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[2]}"-l.png" | xargs curl --silent -o /tmp/weather_tonight.png
  fi
fi
if [ $FLG_T -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"$TITLE_TOMORROW"\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s / %-5s  \t%s\n" ${TEMP_T[0]} "${TEMP_T[1]}" "$PHRASE_T"
  [ $F_PROB -eq 1 ] && echo ${DATA_TOMORROW[3]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TOMORROW[5]}" \t" | tr -d '\n'
  [ $F_SNOW -eq 1 ] && echo ${DATA_TOMORROW[7]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo ${DATA_TOMORROW[0]} | tr -d '\n'
  echo
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_T"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png
  fi
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT