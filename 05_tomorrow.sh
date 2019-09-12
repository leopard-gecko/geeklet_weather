# 明日の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# Tomorrowの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
T_COLOR=40

# 天気の詳細（10 簡略表示、14 詳細表示）
detail=14

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/daily-weather-forecast}`
daily_data=`echo "$weather_data" | grep -e 'dailyForecast' | tr '{|}' '\n'`
tomorrow_data=$(echo "$daily_data" | grep -A3 $(date -v+1d '+%Y-%m-%d'))

# 明日の最高・最低気温と天気を表示
hi=`echo "$tomorrow_data" | grep -A1 -m2 '"day"' | sed -n 2p | awk -F\" '{print $4}'`
lo=`echo "$tomorrow_data" | grep -A1 -m2 '"night"' | sed -n 2p | awk -F\" '{print $4}'`

echo "\033[0;${T_COLOR}mTomorrow\033[0m"
printf "$hi/$lo "
echo "$daily_data" | grep -A1 `date -v+1d '+%Y-%m-%d'` | sed -n 2p | awk -v "det=${detail}" -F\" '{print $det}'

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
icon_data=`echo "$tomorrow_data" | grep -m1 'icon' | sed -e 's/.*\"icon\":\([0-9]*\).*/\1/' | tr -cd '0123456789' | awk '{printf "%02d", $1}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_data"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png