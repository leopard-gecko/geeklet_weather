# Looking aheadのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_CP='40;37'

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
LA_DATA=$(echo "$WEATHER_DATA" | grep -A5 '<div class="forecast-summary-header">' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')

# Looking aheadを取得して表示
echo $(printf "\033[0;${COLOR_CP}m")$(echo "$LA_DATA" | grep -A1 '<div class="forecast-summary-header">' | tr -d '\t' | sed -n 2p):$(printf "\033[0m") 
echo "$LA_DATA" | grep -A1 '<div class="forecast-summary-text">' | tr -d '\t' | sed -n 2p