# 明日の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# Tomorrowの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
T_COLOR=40

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
detail=longPhrase

# 何日後？
later=1

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/daily-weather-forecast}`
tomorrow_data=$(echo "$weather_data" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date -v+$(($later))d '+%Y-%m-%d') | tr ',' '\n' | tr -d '"')

# 明日の最高・最低気温と天気を表示
hi=`echo "$tomorrow_data" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
lo=`echo "$tomorrow_data" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

printf "\033[0;${T_COLOR}mTomorrow\033[0m"
# printf " $(echo "$tomorrow_data" | grep 'date:' | awk -F: '{print $2}')"
echo
printf "%s/%s " $hi $lo
echo "$tomorrow_data" | grep -m1 "$detail" | awk -F: '{print $2}'

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
icon_data=`echo "$tomorrow_data" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_data"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png