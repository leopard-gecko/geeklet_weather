# 紫外線、雲量、湿度、気圧、風速・風向きのスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 取得したいデータ（0 取得しない、1 取得する）
uv_index=1      #紫外線
cloud_cover=1   #雲量
humidity=1      #湿度
pressure=1      #気圧
wind=1          #風速・風向き

# 改行表示（0 改行しない、1 改行する）
line_feed=0

# 取得するデータの整理
if [ $uv_index -eq 1 ];    then ui='uv:';         else ui='Dummy'; fi
if [ $cloud_cover -eq 1 ]; then cc='cc:';         else cc='Dummy'; fi
if [ $humidity -eq 1 ];    then hu='\|humidity:'; else hu=''; fi
if [ $pressure -eq 1 ];    then pr='\|pressure:'; else pr=''; fi
if [ $wind -eq 1 ];        then wi='\|wind:';     else wi=''; fi

if [ $line_feed -eq 1 ]; then lf='\\n'; else lf='\\t'; fi

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/current-weather}`
cur_data=$(echo "$weather_data" | grep 'curCon' | tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 現在の雲量、湿度、風速・風向きを取得して表示
echo "$cur_data" | grep -A2 $(echo $ui) | tr '\n' ':' | awk -F: '{print "UV index: "$6,"("$4")"}' | tr '\n' "$(echo $lf)"
echo "$cur_data" | grep ''$(echo $cc)$(echo $hu)$(echo $pr)$(echo $wi)'' | tr '\n' "$(echo $lf)" | sed -e s/cc:/'Cloud Cover: '/g -e s/humidity:/'Humidity: '/g -e s/pressure:/'Pressure: '/g -e s/mbar/'hPa'/g -e s/wind:/'Wind: '/g | sed s/"`printf '\t'`"/'    '/g
