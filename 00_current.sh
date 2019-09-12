# 現在の温度と天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`

# 現在の温度と天気を取得して表示
echo "$weather_data" | grep -e 'curCon' | awk -F\" '{print $14,$10}'

# 天気アイコンのナンバーを取得し二桁でゼロパディングする
icon_cur=`echo "$weather_data" | grep -e 'curCon' | sed -e 's/.*\"icon\":\([0-9]*\).*/\1/' | tr -cd '0123456789' | awk '{printf "%02d", $1}'`

# 天気アイコンナンバーをURLに変換して画像を保存
echo "https://vortex.accuweather.com/adc2010/images/icons-numbered/"$icon_cur"-xl.png" | xargs curl --silent -o /tmp/weather_now.png

# アイコンのURLはこれでも良い
# https://vortex.accuweather.com/adc2010/images/slate/icons/40-xl.png