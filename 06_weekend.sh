# 週末の天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=44
SUN_COLOR=41

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=longPhrase

# 日付を表示する？（1 簡略表示、2 詳細表示、0 表示しない）
DATE_B=1

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得（日曜日の場合は翌週の週末を取得する）
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
DATA_SAT=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(expr 6 - $(date +%w))d +%Y-%m-%d))
DATA_SUN=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(expr 7 - $(date +%w))d +%Y-%m-%d))

# 土日の最高・最低気温と天気を表示
SAT_HI=$(pickup_word "$(echo "$DATA_SAT" | grep -A1 'day:')"   'dTemp')
SAT_LO=$(pickup_word "$(echo "$DATA_SAT" | grep -A1 'night:')" 'dTemp')
SUN_HI=$(pickup_word "$(echo "$DATA_SUN" | grep -A1 'day:')"   'dTemp')
SUN_LO=$(pickup_word "$(echo "$DATA_SUN" | grep -A1 'night:')" 'dTemp')

printf "\033[0;${SAT_COLOR}m$(pickup_word "$DATA_SAT" 'lDOW:')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(pickup_word "$DATA_SAT" 'date:'))"
[ $DATE_B -eq 2 ] && printf "\t($(pickup_word "$DATA_SAT" 'lDate:'))"
echo
printf "%s/%s " $SAT_HI $SAT_LO
pickup_word "$DATA_SAT" "$DETAIL"

printf "\033[0;${SUN_COLOR}m$(pickup_word "$DATA_SUN" 'lDOW:')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(pickup_word "$DATA_SUN" 'date:'))"
[ $DATE_B -eq 2 ] && printf "\t($(pickup_word "$DATA_SUN" 'lDate:'))"
echo
printf "%s/%s " $SUN_HI $SUN_LO
pickup_word "$DATA_SUN" "$DETAIL"

# 週末の天気アイコン取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
ICON_SAT=$(printf "%02d" $(pickup_word "$DATA_SAT" 'icon'))
ICON_SUN=$(printf "%02d" $(pickup_word "$DATA_SUN" 'icon'))

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_SAT"-l.png" | xargs curl --silent -o /tmp/weather_sat.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_SUN"-l.png" | xargs curl --silent -o /tmp/weather_sun.png

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
