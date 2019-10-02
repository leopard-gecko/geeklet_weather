# 週間天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何日後から？
LATER=1
# 何日間？
DAYS=7

# 日付を表示する？（1 表示する、0 表示しない）
DATE_B=1
# 曜日を表示する？（1 表示する、0 表示しない）
DOW=1

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=phrase

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=34
SUN_COLOR=31

# 元データ取得
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
for (( i = 0; i < $DAYS; ++i ))
do
DATA_WEEK[$i]=$(echo "$WEATHER_DATA" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date -v+$(($LATER+$i))d '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')
done

# 日付、曜日、最高・最低気温、天気を表示
for (( i = 0; i < $DAYS; ++i ))
do
HI[$i]=`echo "${DATA_WEEK[$i]}" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
LO[$i]=`echo "${DATA_WEEK[$i]}" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`
[ $DATE_B -eq 1 ] && printf "%5s " "$(echo "${DATA_WEEK[$i]}" | grep 'date:' | awk -F: '{print $2}')"
[ $DOW -eq 1 ] && printf "($(echo "${DATA_WEEK[$i]}" | grep -m1 'dow:' | awk -F: '{print $2}' | sed -E s/Sat\|土/`printf "\033[0;${SAT_COLOR}m"`\&/ | sed -E s/Sun\|日/`printf "\033[0;${SUN_COLOR}m"`\&/ | sed -E 's/$/'`printf "\033[0m"`'/'))\t "
printf "%3s/%3s  " ${HI[$i]} ${LO[$i]}
echo "${DATA_WEEK[$i]}" | grep -m1 "$DETAIL" | awk -F: '{print $2}'
done

# 天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
for (( i = 0; i < $DAYS; ++i ))
do
ICON_WEEK[$i]=`echo "${DATA_WEEK[$i]}" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_WEEK[$i]}"-l.png" | xargs curl --silent -o /tmp/weather_week_$(($i)).png
done

# 画像GeekletをRefleshする
osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT
