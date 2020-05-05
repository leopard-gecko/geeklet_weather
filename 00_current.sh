# 現在の温度と天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
DATA_CUR=$(echo "$WEATHER_DATA" | grep -A30 'panel panel-fade-in card current' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')

# 現在の温度と天気を取得して表示
TEMP=$(echo "$DATA_CUR" | grep -A1 '<span class="high">' | sed -n 2p)
PHRASE=$(echo "$DATA_CUR" | grep -A1 '<div class="cond">' | sed -n 2p)
echo $TEMP $PHRASE

# 天気アイコンのナンバーを取得し画像を保存
ICON_CUR=$(printf "%02d" $(echo "$DATA_CUR" | grep 'img class="weather-icon icon"' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "."))
echo "https://vortex.accuweather.com/adc2010/images/icons-numbered/"$ICON_CUR"-xl.png" | xargs curl --silent -o /tmp/weather_now.png

# シンプルなデザインの天気アイコンを使いたい場合はこれに書き換える
# https://vortex.accuweather.com/adc2010/images/slate/icons/"$ICON_CUR"-xl.png

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
