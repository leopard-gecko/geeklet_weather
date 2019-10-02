# 最高気温と最低気温のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 元データ取得
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
DATA_TODAY=$(echo "$WEATHER_DATA" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')

# 今日の最高温度と最低温度を取得して表示
HI=`echo "$DATA_TODAY" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
LO=`echo "$DATA_TODAY" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

echo $HI / $LO