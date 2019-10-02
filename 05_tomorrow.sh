# 明日の天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL="${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}"

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

# 元データ取得
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
DATA_TOMORROW=$(echo "$WEATHER_DATA" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date -v+$(($LATER))d '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')
DATA_LOCALE=$(echo "$WEATHER_DATA" | grep -e 'pageLocale' |  tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 明日の最高・最低気温と天気を表示
HI=`echo "$DATA_TOMORROW" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
LO=`echo "$DATA_TOMORROW" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

[ $DOW -eq 0 ] && printf "\033[0;${T_COLOR}m$(echo "$DATA_LOCALE" | grep -m1 'tomorrow:' | awk -F: '{print $2}')\033[0m   "
[ $DOW -eq 1 ] && printf "\033[0;${T_COLOR}m$(echo "$DATA_TOMORROW" | grep -m1 'lDOW:' | awk -F: '{print $2}')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(echo "$DATA_TOMORROW" | grep 'date:' | awk -F: '{print $2}'))"
[ $DATE_B -eq 2 ] && printf "\t($(echo "$DATA_TOMORROW" | grep 'lDate:' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $HI $LO
echo "$DATA_TOMORROW" | grep -m1 "$DETAIL" | awk -F: '{print $2}'

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
ICON_TOMORROW=`echo "$DATA_TOMORROW" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_TOMORROW"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png

# 画像GeekletをRefleshする
osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT
