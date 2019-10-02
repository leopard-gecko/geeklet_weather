# Minute Castのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 120分間天気に変化がない時のMINUTECASTの表示（0 変化がなければ表示しない、1 常に表示する）
MC_SHOW=0

# 元データ取得
WEATHER_DATA=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $WEATHER_URL`
DATA_MC=$(echo "$WEATHER_DATA" | grep 'minuteCastSummary' | tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# MINUTECASTを取得して表示
if [ $(echo "$DATA_MC" | grep 'typeId' | awk -F: '{print $2}') -ne 0 ] || [ $MC_SHOW -eq 1 ];then
  echo "$DATA_MC" | grep 'phrase' | awk -F: '{print $2}'
fi