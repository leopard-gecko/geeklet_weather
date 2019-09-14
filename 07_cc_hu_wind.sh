# 雲量、湿度、風速・風向きのスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/current-weather}`
cur_data=`echo "$weather_data" | grep 'curCon' | tr '{|}' '\n' | tr ',' '\n' | tr -d '"'`

# 現在の雲量、湿度、風速・風向きを取得して表示
echo "$cur_data" | grep 'cc:\|humidity:\|wind:' | tr '\n' '\t' | sed -e s/cc:/'Cloud Cover: '/g -e s/humidity:/'Humidity: '/g -e s/wind:/'Wind: '/g
