# 明日の天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# Tomorrowまたは曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
T_COLOR="40"

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=longPhrase

# 何日後？
LATER=1

# 曜日を表示する？（1 表示する、0 表示しない）
DOW=0
# 日付を表示する？（1 簡略表示、2 詳細表示、0 表示しない）
DATE_B=0

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
DATA_TOMORROW=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(($LATER))d '+%Y-%m-%d'))
DATA_LOCALE=$(pickup_data "$WEATHER_DATA" 'pageLocale')

# 明日の最高・最低気温と天気を表示
HI=$(pickup_word "$(echo "$DATA_TOMORROW" | grep -A1 'day:')"   'dTemp')
LO=$(pickup_word "$(echo "$DATA_TOMORROW" | grep -A1 'night:')" 'dTemp')

[ $DOW -eq 0 ] && printf "\033[0;${T_COLOR}m$(pickup_word "$DATA_LOCALE" 'tomorrow:')\033[0m   "
[ $DOW -eq 1 ] && printf "\033[0;${T_COLOR}m$(pickup_word "$DATA_TOMORROW" 'lDOW:')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(pickup_word "$DATA_TOMORROW" 'date:'))"
[ $DATE_B -eq 2 ] && printf "\t($(pickup_word "$DATA_TOMORROW" 'lDate:'))"
echo
printf "%s/%s " $HI $LO
pickup_word "$DATA_TOMORROW" "$DETAIL"

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
ICON_TOMORROW=$(printf "%02d" $(pickup_word "$DATA_TOMORROW" 'icon'))

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TOMORROW"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
