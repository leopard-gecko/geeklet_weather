# 最高気温と最低気温のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
today_data=$(echo "$weather_data" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')

# 今日の最高温度と最低温度を取得して表示
hi=`echo "$today_data" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
lo=`echo "$today_data" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

echo $hi / $lo