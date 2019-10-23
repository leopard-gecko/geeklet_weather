# Minute Castのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 120分間天気に変化がない時のMINUTECASTの表示（0 変化がなければ表示しない、1 常に表示する）
MC_SHOW=0

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent $WEATHER_URL)
DATA_MC=$(pickup_data "$WEATHER_DATA" 'minuteCastSummary')

# MINUTECASTを取得して表示
if [ $(pickup_word "$DATA_MC" 'typeId') -ne 0 ] || [ $MC_SHOW -eq 1 ];then
pickup_word "$DATA_MC" 'phrase'
fi
