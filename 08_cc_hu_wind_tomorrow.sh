# 明日の紫外線、雲量、風速・風向き、降水確率のスクリプト

# 場所のURL （日本語表記にしたい場合は/de/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 何日後？
later=1

# 取得したいデータ（0 取得しない、1 取得する）
uv_index=1      #紫外線
cloud_cover=1   #雲量
wind=1          #風速・風向き
precip=1        #降水確率

# 改行表示（0 改行しない、1 改行する）
line_feed=0

# 取得するデータの整理
if [ $uv_index -eq 1 ];    then ui='uv:';         else ui='Dummy'; fi
if [ $cloud_cover -eq 1 ]; then cc='cc:';         else cc='Dummy'; fi
if [ $wind -eq 1 ];        then wi='\|wind:';     else wi=''; fi
if [ $precip -eq 1 ];      then pr='\|precip:';   else pr=''; fi

if [ $line_feed -eq 1 ]; then lf='\\n'; else lf='\\t'; fi

# 元データ取得
weather_data=$(curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/daily-weather-forecast}?day=$(($later)))
tomorrow_data=$(echo "$weather_data" | grep 'var today' | tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"' | awk '/date:/,/lDate:/')
locale_data=$(echo "$weather_data" | grep -e 'pageLocale' |  tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 現在の雲量、湿度、風速・風向きを取得して表示
echo "$tomorrow_data" | grep -A2 $(echo $ui) | tr '\n' ':' | awk -F: -v uvi="$(echo "$locale_data" | grep 'maxUV:' | awk -F: '{print $2}')" '{print uvi": "$6,"("$4")"}' | sed "s/$/    /g" | tr '\n' "$(echo $lf)"
echo "$tomorrow_data" | grep ''$(echo $cc$wi$pr)'' | sed "s/$/    /g" | tr '\n' "$(echo $lf)" | sed -e s/cc:/"$(echo "$locale_data" | grep 'cloudCover:' | awk -F: '{print $2}'): "/g -e s/wind:/"$(echo "$locale_data" | grep 'wind:' | awk -F: '{print $2}'): "/g -e s/precip:/"$(echo "$locale_data" | grep 'precip:' | awk -F: '{print $2}'): "/g
