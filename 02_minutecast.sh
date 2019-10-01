# Minute Castのスクリプト

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 120分間天気に変化がない時のMINUTECASTの表示（0 変化がなければ表示しない、1 常に表示する）
mc_show=0

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
mc_data=$(echo "$weather_data" | grep 'minuteCastSummary' | tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# MINUTECASTを取得して表示
if [ $(echo "$mc_data" | grep 'typeId' | awk -F: '{print $2}') -ne 0 ] || [ $mc_show -eq 1 ];then
echo "$mc_data" | grep 'phrase' | awk -F: '{print $2}'
fi