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
LA_DATA=$(echo "$WEATHER_DATA" | grep -A7 'inline-cta-banner looking-ahead' | tr -d '\t')
LOCALE_LA=$(echo "$LA_DATA" | grep -A1 'banner-header' | sed -n 2p)

# Looking aheadを取得して表示
[ -n "$LOCALE_LA" ] && echo $(printf "\033[0;${COLOR_CP}m")$LOCALE_LA:$(printf "\033[0m") 
echo "$LA_DATA" | grep -A1 'banner-text' | sed -n 2p