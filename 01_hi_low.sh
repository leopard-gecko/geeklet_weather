# 最高気温と最低気温のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_d_n_word() { echo "$1" | grep -A1 $2 | grep -m1 $3 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
DATA_TODAY=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date '+%Y-%m-%d'))

# 今日の最高温度と最低温度を取得して表示
HI=$(pickup_d_n_word "$DATA_TODAY" 'day:' 'dTemp')
LO=$(pickup_d_n_word "$DATA_TODAY" 'night:' 'dTemp')

echo $HI / $LO
