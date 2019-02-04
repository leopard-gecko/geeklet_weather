# 最高気温と最低気温のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# プロキシ
weather_proxy=""

# 元データ取得
weather_today=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' $weather_proxy --silent ${weather_url/weather-forecast/daily-weather-forecast}"?day=1"`

# 今日の最高温度と最低温度を取得して表示
echo "$weather_today" | grep -A 6 'Today\|Tonight' | grep  -e 'large-temp\|small-temp\|temp-label tonight selected' | sed -e 's/<[^>]*>//g' | sed -e 's/&deg;/°/g' -e 's/^ *//' | tr "\r\n" " "