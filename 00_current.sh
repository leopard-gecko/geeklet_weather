# 現在の温度と天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
DATA_CUR=$(pickup_data "$WEATHER_DATA" 'curCon')

# 現在の温度と天気を取得して表示
echo $(pickup_word "$DATA_CUR" 'temp') $(pickup_word "$DATA_CUR" 'phrase')

# 天気アイコンのナンバーを取得し二桁でゼロパディングする
ICON_CUR=$(printf "%02d" $(pickup_word "$DATA_CUR" 'icon'))

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
