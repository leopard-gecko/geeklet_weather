# 明日の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# TomorrowまたはEarlyの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
T_COLOR=40

# 元データ取得
weather_data=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`

# 明日（または早朝）の天気を表示
echo "$weather_data" | grep -e '>Tomorrow<\|>Early AM<' | sed -e 's/<[^>]*>//g'  -e 's/^ *//' -e 's/[[:cntrl:]]//g' | awk -v t_color="$T_COLOR" '{print "\x1b["t_color"m"$0"\x1b[0m"}'
echo "$weather_data" | grep -A 9 '>Tomorrow<\|>Early AM<' | grep  -e 'large-temp\|cond' | sed -e 's/<[^>]*>//g' -e 's/&deg;/°/g' -e 's/^ *//' -e 's/[[:cntrl:]]//g' | tr "\r\n" " "

# 明日の天気アイコンのナンバーを取得しゼロパディングする
icon_data=`echo "$weather_data" | grep -A 2 '>Tomorrow<\|>Early AM<' | grep 'icon' | sed -e 's/[^"]*"\([^"]*\)".*/\1/' | tr -cd '0123456789' | awk '{printf "%02d", $1}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_data"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png
