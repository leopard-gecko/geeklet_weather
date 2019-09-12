# 最高気温と最低気温のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_today=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`

# 今日の最高温度と最低温度を取得して表示
hi=`echo "$weather_today" | grep -e 'dailyForecast' | tr '{|}' '\n' | grep -A1 -m2 '"day"' | sed -n 2p | awk -F\" '{print $4}'`
lo=`echo "$weather_today" | grep -e 'dailyForecast' | tr '{|}' '\n' | grep -A1 -m2 '"night"' | sed -n 2p | awk -F\" '{print $4}'`

echo $hi / $lo