# 週末の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=44
SUN_COLOR=41

# 天気の詳細（10 簡略表示、14 詳細表示）
detail=14

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
daily_data=`echo "$weather_data" | grep -e 'dailyForecast' | tr '{|}' '\n'`
sat_data=`echo "$daily_data" | grep -A1 -B2 -m2 'Saturday' | sed -n 1,4p`
sun_data=`echo "$daily_data" | grep -A1 -B2 -m2 'Sunday' | sed -n 1,4p`

# 土日の最高・最低気温と天気を表示
sat_hi=`echo "$sat_data" | grep -A1 -m2 '"day"' | sed -n 2p | awk -F\" '{print $4}'`
sat_lo=`echo "$sat_data" | grep -A1 -m2 '"night"' | sed -n 2p | awk -F\" '{print $4}'`
sun_hi=`echo "$sun_data" | grep -A1 -m2 '"day"' | sed -n 2p | awk -F\" '{print $4}'`
sun_lo=`echo "$sun_data" | grep -A1 -m2 '"night"' | sed -n 2p | awk -F\" '{print $4}'`

echo "\033[0;${SAT_COLOR}mSaturday\033[0m"
printf "$sat_hi/$sat_lo "
echo "$sat_data" | grep 'phrase' | awk -v "det=${detail}" -F\" '{print $det}' | sed -n 1p

echo "\033[0;${SUN_COLOR}mSunday\033[0m"
printf "$sun_hi/$sun_lo "
echo "$sun_data" | grep 'phrase' | awk -v "det=${detail}" -F\" '{print $det}' | sed -n 1p

# 週末の天気アイコン取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
icon_sat=`echo "$sat_data" | grep -m1 'icon' | sed -e 's/.*\"icon\":\([0-9]*\).*/\1/' | tr -cd '0123456789' | awk '{printf "%02d", $1}'`
icon_sat=`printf "%.2d\n" $icon_sat`
icon_sun=`echo "$sun_data" | grep -m1 'icon' | sed -e 's/.*\"icon\":\([0-9]*\).*/\1/' | tr -cd '0123456789' | awk '{printf "%02d", $1}'`
icon_sun=`printf "%.2d\n" $icon_sun`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sat"-l.png" | xargs curl --silent -o /tmp/weather_sat.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sun"-l.png" | xargs curl --silent -o /tmp/weather_sun.png