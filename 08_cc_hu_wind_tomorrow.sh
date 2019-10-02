# 明日の紫外線、雲量、風速・風向き、降水確率のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/de/を/ja/に書き換える）
WEATHER_URL="${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}"

# 何日後？
LATER=1

# 取得したいデータ（0 取得しない、1 取得する）
UV_INDEX=1      #紫外線
CLOUD_COVER=1   #雲量
WIND=1          #風速・風向き
PRECIP=1        #降水確率

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 取得するデータの整理
if [ $UV_INDEX -eq 1 ];    then ui='uv:';         else ui='Dummy'; fi
if [ $CLOUD_COVER -eq 1 ]; then cc='cc:';         else cc='Dummy'; fi
if [ $WIND -eq 1 ];        then wi='\|wind:';     else wi=''; fi
if [ $PRECIP -eq 1 ];      then pr='\|precip:';   else pr=''; fi

if [ $LINE_FEED -eq 1 ]; then lf='\\n'; else lf='\\t'; fi

# 元データ取得
WEATHER_DATA=$(curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast}?day=$(($LATER+1)))
DATA_TOMORROW=$(echo "$WEATHER_DATA" | grep 'var today' | tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"' | awk '/date:/,/lDate:/')
DATA_LOCALE=$(echo "$WEATHER_DATA" | grep -e 'pageLocale' |  tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 現在の雲量、湿度、風速・風向きを取得して表示
echo "$DATA_TOMORROW" | grep -A2 $(echo $ui) | tr '\n' ':' | awk -F: -v uvi="$(echo "$DATA_LOCALE" | grep 'maxUV:' | awk -F: '{print $2}')" '{print uvi": "$6,"("$4")"}' | sed "s/$/    /g" | tr '\n' "$(echo $lf)"
echo "$DATA_TOMORROW" | grep ''$(echo $cc$wi$pr)'' | sed "s/$/    /g" | tr '\n' "$(echo $lf)" | sed -e s/cc:/"$(echo "$DATA_LOCALE" | grep 'cloudCover:' | awk -F: '{print $2}'): "/g -e s/wind:/"$(echo "$DATA_LOCALE" | grep 'wind:' | awk -F: '{print $2}'): "/g -e s/precip:/"$(echo "$DATA_LOCALE" | grep 'precip:' | awk -F: '{print $2}'): "/g
