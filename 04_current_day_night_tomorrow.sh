# 現在、日中、夜間、明日のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/ja/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 表示する要素（1 表示する、0 表示しない）
FLG_C=0  # 現在
FLG_D=1  # 日中
FLG_N=1  # 夜間
FLG_T=1  # 明日
# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=phrase
# 天気アイコンを取得する？（1 取得する、0 取得しない）
ICON_B=1
# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
C_COLOR="37;40"

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_d_n_word() { echo "$1" | grep -A7 $2 | grep -m1 $3 | awk -F: '{print $2}'; }
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA="$(curl -H "$USER_AGENT" --silent $WEATHER_URL)"
DATA_CUR="$(pickup_data "$WEATHER_DATA" 'curCon')"
DATA_TODAY="$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date '+%Y-%m-%d'))"
DATA_TOMORROW="$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+1d '+%Y-%m-%d'))"
DATA_LOCALE="$(pickup_data "$WEATHER_DATA" 'pageLocale')"

# 温度を取得
HI_TODAY=$(pickup_d_n_word "$DATA_TODAY" 'day:' 'dTemp')
LO_TODAY=$(pickup_d_n_word "$DATA_TODAY" 'night:' 'dTemp')
HI_TOMORROW=$(pickup_d_n_word "$DATA_TOMORROW" 'day:' 'dTemp')
LO_TOMORROW=$(pickup_d_n_word "$DATA_TOMORROW" 'night:' 'dTemp')
TEMP_TODAY=$(pickup_word "$DATA_CUR" 'temp')

#  現在、日中、夜間、明日の天気を表示して天気アイコンを取得し保存
if [ $FLG_C -eq 1 ]; then
  echo "\033[0;${C_COLOR}m"$(echo "$DATA_LOCALE" | grep -A2 'CurConPanel:' | grep 'title' | awk -F: '{print $2}')"\033[0m"
  printf "%-5s\n" $TEMP_TODAY
  pickup_word "$DATA_CUR" 'phrase'
  echo
  if [ $ICON_B -eq 1 ]; then
    ICON_CUR=$(printf "%02d" $(pickup_word "$DATA_CUR" 'icon'))
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_CUR"-l.png" | xargs curl --silent -o /tmp/weather_current.png
  fi
fi
if [ $FLG_D -eq 1 ]; then
  printf "\033[0;${C_COLOR}m%s\033[0m\n" $(pickup_word "$DATA_LOCALE" 'today:')
  printf "%-5s %-5s \t☂️: %4s\n" $HI_TODAY $(pickup_word "$DATA_LOCALE" 'high:') $(pickup_d_n_word "$DATA_TODAY" 'day:' 'precip')
  pickup_d_n_word "$DATA_TODAY" 'day:' "$DETAIL"
  echo
  if [ $ICON_B -eq 1 ]; then
    ICON_TODAY=$(printf "%02d" $(pickup_d_n_word "$DATA_TODAY" 'day:' 'icon'))
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TODAY"-l.png" | xargs curl --silent -o /tmp/weather_today.png
  fi
fi
if [ $FLG_N -eq 1 ]; then
  printf "\033[0;${C_COLOR}m%s\033[0m\n" $(pickup_word "$DATA_LOCALE" 'tonight:')
  printf "%-5s %-5s \t☂️: %4s\n" $LO_TODAY $(pickup_word "$DATA_LOCALE" 'low:') $(pickup_d_n_word "$DATA_TODAY" 'night:' 'precip')
  pickup_d_n_word "$DATA_TODAY" 'night:' "$DETAIL"
  echo
  if [ $ICON_B -eq 1 ]; then
    ICON_TONIGHT=$(printf "%02d" $(pickup_d_n_word "$DATA_TODAY" 'night:' 'icon'))
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TONIGHT"-l.png" | xargs curl --silent -o /tmp/weather_tonight.png
  fi
fi
if [ $FLG_T -eq 1 ]; then
  printf "\033[0;${C_COLOR}m%s\033[0m\n" $(pickup_word "$DATA_LOCALE" 'tomorrow:')
  printf "%-5s/%-5s\t☂️: %4s\n" $HI_TOMORROW $LO_TOMORROW $(pickup_word "$DATA_TOMORROW" "precip")
  pickup_d_n_word "$DATA_TOMORROW" 'day:' "$DETAIL"
  if [ $ICON_B -eq 1 ]; then
    ICON_TOMORROW=$(printf "%02d" $(pickup_d_n_word "$DATA_TOMORROW" 'day:' 'icon'))
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TOMORROW"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png
  fi
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT