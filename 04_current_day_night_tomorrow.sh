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
# 表示する内容（0 表示しない、1 表示する）
F_TEMP=1    # 温度・天気
F_PRECIP=1  # 降水確率・降水量（現在の天気のみ湿度と気圧）
F_UV=0      # 紫外線量
# 各段の間の改行数
NLF=1
# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト、二桁目が4で背景の色指定）
COLOR_CP="37;40"
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# データ整理用関数
pickup_data_1() { echo "$1" | awk /$2/,/$3/ | grep -A1 '<p>' | grep -v '<p>' | perl -pe 's/--\n//g' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'; }
pickup_data_2() { echo "$1" | grep -A1 $2 | grep -v $2 | perl -pe 's/--\n//g'; }

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA="$(curl -A "$USER_AGENT" --silent $WEATHER_URL)"
WEATHER_TODAY=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
WEATHER_TOMORROW=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast}?day=2)
DATA_NOW="$(echo "$WEATHER_DATA" | awk '/a class="panel panel-fade-in card current "/,/threeday-panel-next/' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')"
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(pickup_data_1 "$WEATHER_TODAY" '<div class="accordion-item-content accordion-item-content">' '<div class="short-list">'))
DATA_TODAY_DAY=($(pickup_data_1 "$WEATHER_TODAY" '<div class="details-card card panel details allow-wrap">' '<div class="quarter-day-links">' | sed -n 1,11p))
DATA_TODAY_NIT=($(pickup_data_1 "$WEATHER_TODAY" '<div class="details-card card panel details allow-wrap">' '<div class="quarter-day-links">' | sed -n 12,21p))
DATA_TOMORROW=($(pickup_data_1 "$WEATHER_TOMORROW" '<div class="details-card card panel details allow-wrap">' '<div class="quarter-day-links">' | sed -n 1,11p))
IFS="$_IFS"

# 各データ取得
_IFS="$IFS";IFS=$'\n'
TITLE=($(pickup_data_2 "$DATA_NOW" '<p class="module-header">'))
TEMP_HI=($(pickup_data_2 "$DATA_NOW" '<span class="high">'))
TEMP_LO=($(pickup_data_2 "$DATA_NOW" '<span class="low">'))
PHRASE=($(pickup_data_2 "$DATA_NOW" '<div class="cond">'))
ICON_NO=($(printf "%02d\n" $(echo "$DATA_NOW" | grep 'img class="weather-icon icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d ".")))
IFS="$_IFS"

#  現在、日中、夜間、明日の天気を表示して天気アイコンを取得し保存
if [ $FLG_C -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[0]}"\033[0m"
  [ $F_TEMP -eq 1 ] && printf "%-4s%-6s  \t%s\n" ${TEMP_HI[0]} ${TEMP_LO[0]} "${PHRASE[0]}"
  [ $F_PRECIP -eq 1 ] && echo ${DATA_CUR[0]}"\t"${DATA_CUR[3]}
  [ $F_UV -eq 1 ] && echo ${DATA_CUR[1]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[0]}"-l.png" | xargs curl --silent -o /tmp/weather_current.png
  fi
fi
if [ $FLG_D -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[1]}"\033[0m"
  [ $F_TEMP -eq 1 ] && printf "%-4s%-6s  \t%s\n" ${TEMP_HI[1]} ${TEMP_LO[1]} "${PHRASE[1]}"
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TODAY_DAY[0]}"\t"${DATA_TODAY_DAY[3]}
  [ $F_UV -eq 1 ] && echo ${DATA_TODAY_DAY[1]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[1]}"-l.png" | xargs curl --silent -o /tmp/weather_today.png
  fi
fi
if [ $FLG_N -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[2]}"\033[0m"
  [ $F_TEMP -eq 1 ] && printf "%-4s%-6s  \t%s\n" ${TEMP_HI[2]} ${TEMP_LO[2]} "${PHRASE[2]}"
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TODAY_NIT[0]}"\t"${DATA_TODAY_NIT[2]}
  [ $F_UV -eq 1 ] && echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[2]}"-l.png" | xargs curl --silent -o /tmp/weather_tonight.png
  fi
fi
if [ $FLG_T -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[3]}"\033[0m"
  [ $F_TEMP -eq 1 ] && printf "%-4s%-6s  \t%s\n" ${TEMP_HI[3]} "${TEMP_LO[3]}" "${PHRASE[3]}"
  [ $F_PRECIP -eq 1 ] && echo ${DATA_TOMORROW[0]}"\t"${DATA_TOMORROW[3]}
  [ $F_UV -eq 1 ] && echo ${DATA_TOMORROW[1]}
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[3]}"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png
  fi
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT