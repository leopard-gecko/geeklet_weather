# Warningのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_CP='41;37'

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
DATA_WN=$(echo "$WEATHER_DATA" | grep -A3 '<div class="alert-banner alert-banner-weather">' | grep '<span>' | sed 's/<[^>]*>//g' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }')

# Warningを取得して表示
echo "$DATA_WN" | sed -E 's/^/'$(printf "\033[0;${COLOR_CP}m")'/' | sed -E 's/$/'$(printf "\033[0m")'/'