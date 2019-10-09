# 本日の日中と夜のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_d_n_word() { echo "$1" | grep -A10 $2 | grep -m1 $3 | awk -F: '{print $2}'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
DATA_TODAY=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date '+%Y-%m-%d'))
DATA_TOMORROW=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+1d '+%Y-%m-%d'))
DATA_LOCALE=$(pickup_data "$WEATHER_DATA" 'pageLocale')

# 今日の日中と夜の天気を取得して表示
echo $(pickup_word "$DATA_LOCALE" 'day:'):"\t\t☂️"$(printf "%5s" $(pickup_d_n_word "$DATA_TODAY" 'day:' 'precip'))" \t"$(pickup_d_n_word "$DATA_TODAY" 'day:' 'phrase')
echo $(pickup_word "$DATA_LOCALE" 'night:'):"\t☂️"$(printf "%5s" $(pickup_d_n_word "$DATA_TODAY" 'night:' 'precip'))" \t"$(pickup_d_n_word "$DATA_TODAY" 'night:' 'phrase')
HI=$(pickup_word "$(echo "$DATA_TOMORROW" | grep -A1 'day:')"   'dTemp')
LO=$(pickup_word "$(echo "$DATA_TOMORROW" | grep -A1 'night:')" 'dTemp')
echo $(pickup_word "$DATA_LOCALE" 'tomorrow:'):"\t☂️"$(printf "%5s" $(pickup_word "$DATA_TOMORROW" 'precip'))" \t"$(pickup_word "$DATA_TODAY" 'phrase')"   "$HI/$LO

# 天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
ICON_DAY=$(printf "%02d" $(pickup_d_n_word "$DATA_TODAY" 'day:' 'icon'))
ICON_NIT=$(printf "%02d" $(pickup_d_n_word "$DATA_TODAY" 'night:' 'icon'))
ICON_TOMORROW=$(printf "%02d" $(pickup_word "$DATA_TOMORROW" 'icon'))
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_DAY"-l.png" | xargs curl --silent -o /tmp/weather_day.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_NIT"-l.png" | xargs curl --silent -o /tmp/weather_night.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TOMORROW"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
