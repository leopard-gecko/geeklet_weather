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
F_CC=1      # 雲量
F_UV_C=0    # 紫外線量
# 日中・夜間・明日で表示する内容（0 表示しない、1 表示する）
F_TEMP_E=1  # 温度・天気
F_PROB=1    # 降水確率
F_PRECIP=1  # 降水量
F_UV=0      # 紫外線量
# 各段の間の改行数
NLF=1
# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト、二桁目が4で背景の色指定）
COLOR_CP="37;40"
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# データ整理用関数
char_conv() { ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'; }
pickup_data_0() { echo "$1" | grep -A1 "$2" | grep -v "$2" | perl -pe 's/--\n//g' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv; }
pickup_data_1() { echo "$1" | awk /"$2"/,/"$3"/ | sed s/'<div class="half-day-card content-module">'/^/g | sed -e '1d' | tr -d '\t'; }

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA="$(curl -A "$USER_AGENT" --silent $WEATHER_URL)"
WEATHER_TODAY="$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})"
WEATHER_TOMORROW="$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/weather-tomorrow})"
DATA_CUR=$(echo "$WEATHER_DATA" | grep -A42 'cur-con-weather-card card-module' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')
_IFS="$IFS";IFS='^'
DATA_TODAY=($(pickup_data_1 "$WEATHER_TODAY" 'half-day-card ' '<div class="quarter-day-ctas">' | sed -e 's/<div class="quarter-day-ctas">/^/g'))
DATA_TOMORROW=($(pickup_data_1 "$WEATHER_TOMORROW" 'half-day-card ' '<div class="quarter-day-ctas">' | sed 's/<div class="quarter-day-ctas">/^/g'))
F_N=0
if [ ${#DATA_TODAY[@]} -eq 1 ]; then
  DATA_TODAY[1]="${DATA_TODAY[0]}"
  DATA_TODAY[0]=''
  F_N=1
fi
IFS="$_IFS"
_IFS="$IFS";IFS=$'\n'
DATA_C=($(echo "$WEATHER_TODAY" | grep -A2 '<div class="detail-item spaced-content">' | grep -e '<div>' -e '--' | tr -d '\t' | perl -pe 's/\n//g' | sed 's/<\/div><div>/: /g' | sed -e 's/<[^>]*>//g' | perl -pe 's/--/\n/g' | char_conv))
DATA_D=($(echo "${DATA_TODAY[0]}" | grep '<p class="panel-item">' | sed -e 's/<span class=\"value\">/: /g' -e 's/<[^>]*>//g' | char_conv))
DATA_N=($(echo "${DATA_TODAY[1]}" | grep '<p class="panel-item">' | sed -e 's/<span class=\"value\">/: /g' -e 's/<[^>]*>//g' | char_conv))
DATA_T=($(echo "${DATA_TOMORROW[0]}" | grep '<p class="panel-item">' | sed -e 's/<span class=\"value\">/: /g' -e 's/<[^>]*>//g' | char_conv))
IFS="$_IFS"

# 各データ取得
TITLE_C=$(echo "$WEATHER_TODAY" | grep -A1 'card-header spaced-content' | grep -v 'card-header spaced-content' | perl -pe 's/--\n//g' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv)
TITLE_D=$(echo "${DATA_TODAY[0]}" | grep '<h2 class="title">' | sed -e 's/<[^>]*>//g' | char_conv)
TITLE_N=$(echo "${DATA_TODAY[1]}" | grep '<h2 class="title">' | sed -e 's/<[^>]*>//g' | char_conv)
TITLE_T_DATE=$(echo "$WEATHER_DATA" | grep -A3 'weather-tomorrow' | grep -A2 '"day"' | grep -v '"day"' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv)
TITLE_T_DOW=$(echo "$WEATHER_DATA" | grep -A2 'weather-tomorrow' | grep 'day' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv)
TITLE_T=$(echo "$TITLE_T_DATE""\t""$TITLE_T_DOW")
TEMP_C=$(echo "$WEATHER_TODAY" | grep 'div class="display-temp"' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv)
TEMP_D=$(echo "${DATA_TODAY[0]}" | grep -A1 'temperature' | grep -v 'temperature' | sed -e 's/<[^>]*>//g' | sed -e 's/--//g' | tr -d '\n' | char_conv)
TEMP_N=$(echo "${DATA_TODAY[1]}" | grep -A1 'temperature' | grep -v 'temperature' | sed -e 's/<[^>]*>//g' | sed -e 's/--//g' | tr -d '\n' | char_conv)
_IFS="$IFS";IFS=$'\n'
TEMP_T=($(echo "$WEATHER_TOMORROW" | grep -A2 '<div class="temperature">' | grep 'span class' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | char_conv))
IFS="$_IFS"
PHRASE_C=$(echo "$DATA_CUR" | grep '<span class="phrase">' | sed -e 's/<[^>]*>//g' |  tr -d '\t')
PHRASE_D=$(echo "${DATA_TODAY[0]}" | grep 'phrase' | sed -e 's/<[^>]*>//g' | char_conv)
PHRASE_N=$(echo "${DATA_TODAY[1]}" | grep 'phrase' | sed -e 's/<[^>]*>//g' | char_conv)
#PHRASE_T=$(echo "$WEATHER_TOMORROW" | grep -m1 '<div class="phrase">' | sed -e 's/<[^>]*>//g' |  tr -d '\t' | char_conv)
PHRASE_T=$(echo "$WEATHER_DATA" | grep -A16 'weather-tomorrow' | grep -m1 'class="phrase"' | sed -e 's/<[^>]*>//g' | tr -d '\t' | char_conv)

ICON_CUR=$(printf "%02d" $(echo "$WEATHER_DATA" | grep '<svg class="weather-icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
ICON_D=$(printf "%02d\n" $(echo "${DATA_TODAY[0]}" | grep 'svg class="icon'  | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
ICON_N=$(printf "%02d\n" $(echo "${DATA_TODAY[1]}" | grep 'svg class="icon'  | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
ICON_T=$(printf "%02d" $(echo "${DATA_TOMORROW[0]}" |  grep 'svg class="icon' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))

#  現在、日中、夜間、明日の天気を表示して天気アイコンを取得し保存
if [ $FLG_C -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"$TITLE_C"\033[0m"
  [ $F_TEMP_C -eq 1 ] && printf "%-5s \t%s\n" $TEMP_C "$PHRASE_C"
  [ $F_HUM -eq 1 ] && echo ${DATA_C[$((3-$F_N))]}" \t" | tr -d '\n'
  [ $F_PRES -eq 1 ] && echo ${DATA_C[$((6-$F_N))]}" \t" | tr -d '\n'
  [ $F_CC -eq 1 ] && echo ${DATA_C[$((7-$F_N))]}" \t" | tr -d '\n'
  if  [ $F_UV_C -eq 1 ]; then
  [ $F_N -eq 0 ] && echo ${DATA_C[0]}" \t" | tr -d '\n'
  fi
  echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_CUR"-l.png" | xargs curl --silent -o /tmp/weather_current.png
  fi
fi
if [ $FLG_D -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"$TITLE_D"\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s \t%s\n" "$TEMP_D" "$PHRASE_D"
  [ $F_PROB -eq 1 ] && echo ${DATA_D[3]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_D[5]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo ${DATA_D[0]}" \t" | tr -d '\n'
  echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_D"-l.png" | xargs curl --silent -o /tmp/weather_today.png
  fi
fi
if [ $FLG_N -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"$TITLE_N"\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s  \t%s\n" "$TEMP_N" "$PHRASE_N"
  [ $F_PROB -eq 1 ] && echo ${DATA_N[2]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_N[4]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo | tr -d '\n'
  echo
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_N"-l.png" | xargs curl --silent -o /tmp/weather_tonight.png
  fi
fi
if [ $FLG_T -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m""$TITLE_T""\033[0m"
  [ $F_TEMP_E -eq 1 ] && printf "%-5s / %-5s  \t%s\n" ${TEMP_T[0]} "${TEMP_T[1]}" "$PHRASE_T"
  [ $F_PROB -eq 1 ] && echo ${DATA_T[3]}" \t" | tr -d '\n'
  [ $F_PRECIP -eq 1 ] && echo ${DATA_T[5]}" \t" | tr -d '\n'
  [ $F_UV -eq 1 ] && echo ${DATA_T[0]} | tr -d '\n'
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