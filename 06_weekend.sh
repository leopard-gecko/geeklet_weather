# 週末の天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL="${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}"

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=44
SUN_COLOR=41

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=longPhrase

# 日付を表示する？（1 簡略表示、2 詳細表示、0 表示しない）
DATE_B=1

# 元データ取得（日曜日の場合は翌週の週末を取得する）
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
DATA_DAILY=`echo "$WEATHER_DATA" | grep -e 'dailyForecast' | tr '{|}' '\n'`
DATA_SAT=$(echo "$DATA_DAILY" | grep -A3 $(date -v+$(expr 6 - $(date +%w))d +%Y-%m-%d) | sed s/',"'/\\$'\n'/g | tr -d '"')
DATA_SUN=$(echo "$DATA_DAILY" | grep -A3 $(date -v+$(expr 7 - $(date +%w))d +%Y-%m-%d) | sed s/',"'/\\$'\n'/g | tr -d '"')

# 土日の最高・最低気温と天気を表示
SAT_HI=`echo "$DATA_SAT" | grep -A1 'day:'   | grep 'dTemp' | awk -F: '{print $2}'`
SAT_LO=`echo "$DATA_SAT" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`
SUN_HI=`echo "$DATA_SUN" | grep -A1 'day:'   | grep 'dTemp' | awk -F: '{print $2}'`
SUN_LO=`echo "$DATA_SUN" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

printf "\033[0;${SAT_COLOR}m$(echo "$DATA_SAT" | grep -m1 'lDOW:' | awk -F: '{print $2}')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(echo "$DATA_SAT" | grep -m1 'date:' | awk -F: '{print $2}'))"
[ $DATE_B -eq 2 ] && printf "\t($(echo "$DATA_SAT" | grep -m1 'lDate:' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $SAT_HI $SAT_LO
echo "$DATA_SAT" | grep -m1 "$DETAIL" | awk -F: '{print $2}'

printf "\033[0;${SUN_COLOR}m$(echo "$DATA_SUN" | grep -m1 'lDOW:' | awk -F: '{print $2}')\033[0m   "
[ $DATE_B -eq 1 ] && printf "\t($(echo "$DATA_SUN" | grep -m1 'date:' | awk -F: '{print $2}'))"
[ $DATE_B -eq 2 ] && printf "\t($(echo "$DATA_SUN" | grep -m1 'lDate:' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $SUN_HI $SUN_LO
echo "$DATA_SUN" | grep -m1 "$DETAIL" | awk -F: '{print $2}'

# 週末の天気アイコン取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
ICON_SAT=`echo "$DATA_SAT" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`
ICON_SUN=`echo "$DATA_SUN" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_SAT"-l.png" | xargs curl --silent -o /tmp/weather_sat.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_SUN"-l.png" | xargs curl --silent -o /tmp/weather_sun.png

# 画像GeekletをRefleshする
osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT