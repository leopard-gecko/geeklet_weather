# 週末の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=44
SUN_COLOR=41

# 元データ取得
weather_weekend=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/weekend-weather}`

# 土日の天気を表示
echo "\033[0;${SAT_COLOR}mSaturday\033[0m"
echo "$weather_weekend" | grep -A 9 'Saturday' | grep  -e 'large-temp\|cond' | sed -e 's/<[^>]*>//g' | sed -e 's/&deg;/°/g' -e 's/^ *//' | tr "\r\n" " "
echo "\n\033[0;${SUN_COLOR}mSunday\033[0m"
echo "$weather_weekend" | grep -A 9 'Sunday' | grep  -e 'large-temp\|cond' | sed -e 's/<[^>]*>//g' | sed -e 's/&deg;/°/g' -e 's/^ *//' | tr "\r\n" " "

# 週末の天気アイコン取得
icon_sat=`echo "$weather_weekend" | grep -A 2 'Saturday' | grep 'icon' | sed -e 's/^ *//' -e s/'<div class=\"icon '//g -e s/' \"><\/div>'//g -e s/i-//g -e 's/\([0-9]*\).*/\1/' | tr -d '\n' | tr -d '\r'`
icon_sat=`printf "%.2d\n" $icon_sat`
icon_sun=`echo "$weather_weekend" | grep -A 2 'Sunday' | grep 'icon' | sed -e 's/^ *//' -e s/'<div class=\"icon '//g -e s/' \"><\/div>'//g -e s/i-//g -e 's/\([0-9]*\).*/\1/' | tr -d '\n' | tr -d '\r'`
icon_sun=`printf "%.2d\n" $icon_sun`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sat"-l.png" | xargs curl --silent -o /tmp/weather_sat.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sun"-l.png" | xargs curl --silent -o /tmp/weather_sun.png
