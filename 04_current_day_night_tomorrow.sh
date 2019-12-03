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
# 温度を表示する？（0 表示しない、1 表示する）
F_TEMP=1
# 天気の詳細（0 表示しない、1 表示する）
DETAIL=1
# 各段の間の改行数
NLF=1
# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_CP="37;40"
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA="$(curl -A "$USER_AGENT" --silent $WEATHER_URL)"
DATA_NOW="$(echo "$WEATHER_DATA" | awk '/a class="panel panel-fade-in card current "/,/threeday-panel-next/' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')"

# 各データ取得
_IFS="$IFS";IFS=$'\n'
TITLE=($(echo "$DATA_NOW" | grep -A1 '<p class="module-header">' | grep -v '<p class="module-header">' | perl -pe 's/--\n//g'))
TEMP_HI=($(echo "$DATA_NOW" | grep -A1 '<span class="high">' | grep -v '<span class="high">' | perl -pe 's/--\n//g'))
TEMP_LO=($(echo "$DATA_NOW" | grep -A1 '<span class="low">' | grep -v '<span class="low">' | perl -pe 's/--\n//g'))
PHRASE=($(echo "$DATA_NOW" | grep -A1 '<div class="cond">' | grep -v '<div class="cond">' | perl -pe 's/--\n//g'))
ICON_NO=($(printf "%02d\n" $(echo "$DATA_NOW" | grep 'img class="weather-icon icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d ".")))
IFS="$_IFS"

#  現在、日中、夜間、明日の天気を表示して天気アイコンを取得し保存
if [ $FLG_C -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[0]}"\033[0m"
  [ $F_TEMP -eq 1 ] && echo ${TEMP_HI[0]} ${TEMP_LO[0]}
  [ $DETAIL -eq 1 ] && echo ${PHRASE[0]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[0]}"-l.png" | xargs curl --silent -o /tmp/weather_current.png
  fi
fi
if [ $FLG_D -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[1]}"\033[0m"
  [ $F_TEMP -eq 1 ] && echo ${TEMP_HI[1]} ${TEMP_LO[1]}
  [ $DETAIL -eq 1 ] && echo ${PHRASE[1]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[1]}"-l.png" | xargs curl --silent -o /tmp/weather_today.png
  fi
fi
if [ $FLG_N -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[2]}"\033[0m"
  [ $F_TEMP -eq 1 ] && echo ${TEMP_HI[2]} ${TEMP_LO[2]}
  [ $DETAIL -eq 1 ] && echo ${PHRASE[2]}
  for (( m=0; m < $NLF; ++m)); do echo; done
  if [ $F_ICON -eq 1 ]; then
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_NO[2]}"-l.png" | xargs curl --silent -o /tmp/weather_tonight.png
  fi
fi
if [ $FLG_T -eq 1 ]; then
  echo "\033[0;${COLOR_CP}m"${TITLE[3]}"\033[0m"
  [ $F_TEMP -eq 1 ] && echo ${TEMP_HI[3]} ${TEMP_LO[3]}
  [ $DETAIL -eq 1 ] && echo ${PHRASE[3]}
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