# 現在の温度と天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
cur_data=$(echo "$weather_data" | grep 'curCon' | cut -d"{" -f2 | cut -d"}" -f1 | sed s/',"'/\\$'\n'/g | tr -d '"')

# 現在の温度と天気を取得して表示
echo "$cur_data" | grep 'phrase\|temp' | tr '\n' ':' | awk -F: '{print $4,$2}'

# 天気アイコンのナンバーを取得し二桁でゼロパディングする
icon_cur=`echo "$cur_data"| grep 'icon' | awk -F: '{printf "%02d",$2}'`

# 天気アイコンナンバーをURLに変換して画像を保存
echo "https://vortex.accuweather.com/adc2010/images/icons-numbered/"$icon_cur"-xl.png" | xargs curl --silent -o /tmp/weather_now.png

# シンプルなデザインの天気アイコンを使いたい場合はこれに書き換える
# https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_cur"-xl.png
