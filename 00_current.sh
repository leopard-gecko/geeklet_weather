# 現在の温度と天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL="${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}"

# 元データ取得
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
DATA_CUR=$(echo "$WEATHER_DATA" | grep 'curCon' | cut -d"{" -f2 | cut -d"}" -f1 | sed s/',"'/\\$'\n'/g | tr -d '"')

# 現在の温度と天気を取得して表示
echo $(echo "$DATA_CUR" | grep 'temp' | awk -F: '{print $2}') $(echo "$DATA_CUR" | grep 'phrase' | awk -F: '{print $2}')

# 天気アイコンのナンバーを取得し二桁でゼロパディングする
ICON_CUR=`echo "$DATA_CUR"| grep 'icon' | awk -F: '{printf "%02d",$2}'`

# 天気アイコンナンバーをURLに変換して画像を保存
echo "https://vortex.accuweather.com/adc2010/images/icons-numbered/"$ICON_CUR"-xl.png" | xargs curl --silent -o /tmp/weather_now.png

# シンプルなデザインの天気アイコンを使いたい場合はこれに書き換える
# https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_CUR"-xl.png

# 画像GeekletをRefleshする
osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT
