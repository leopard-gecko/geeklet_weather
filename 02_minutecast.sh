# Minute Castのスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`

# MINUTECASTを取得して表示
echo "$weather_data" | grep -e 'minuteCastSummary' | awk -F\" '{print $4}' | grep -v -e 'No precipitation' -e 'temporarily unavailable'