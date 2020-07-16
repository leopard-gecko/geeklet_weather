# Minute Castのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 見出しの色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_CP='0'

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
DATA_MC=$(echo "$WEATHER_DATA" | grep -A7 'minutecast-banner' | tr -d '\t')

# MINUTECASTを取得して表示
TITLE=$(echo "$DATA_MC" | grep -A1 'banner-header' | sed -n 2p)
PHRASE=$(echo "$DATA_MC" | grep -A1 'banner-text' | sed -n 2p)
[ -n "$TITLE" ] && echo $(printf "\033[0;${COLOR_CP}m")"$TITLE:$(printf "\033[0m") $PHRASE"
#[ -n "$TITLE" ] && echo "$PHRASE"