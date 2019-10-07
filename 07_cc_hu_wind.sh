# 雲量、湿度、気圧、風速・風向き、紫外線のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 取得したいデータ（0 取得しない、1 取得する）
UV_INDEX=1      #紫外線
CLOUD_COVER=1   #雲量
HUMIDITY=1      #湿度
PRESSURE=1      #気圧
WIND=1          #風速・風向き

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 取得するデータの整理
if [ $UV_INDEX -eq 1 ];    then UI='uv:';         else UI='Dummy'; fi
if [ $CLOUD_COVER -eq 1 ]; then CC='cc:';         else CC='Dummy'; fi
if [ $HUMIDITY -eq 1 ];    then HU='\|humidity:'; else HU=''; fi
if [ $PRESSURE -eq 1 ];    then PR='\|pressure:'; else PR=''; fi
if [ $WIND -eq 1 ];        then WI='\|wind:';     else WI=''; fi

if [ $LINE_FEED -eq 1 ]; then LF='\\n'; else LF='\\t'; fi

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
DATA_CUR=$(pickup_data "$WEATHER_DATA" 'curCon')
DATA_LOCALE=$(pickup_data "$WEATHER_DATA" 'pageLocale')

# 現在の雲量、湿度、風速・風向きを取得して表示
echo "$DATA_CUR" | grep -A2 $(echo $UI) | tr '\n' ':' | awk -F: -v uvi="$(pickup_word "$DATA_LOCALE" 'uv:')" '{print uvi": "$6,"("$4")"}' | tr '\n' "$(echo $LF)"
echo "$DATA_CUR" | grep ''$(echo $CC)$(echo $HU)$(echo $PR)$(echo $WI)'' | tr '\n' "$(echo $LF)" | sed -e s/cc:/"$(pickup_word "$DATA_LOCALE" 'cloudCover:'): "/g -e s/humidity:/"$(pickup_word "$DATA_LOCALE" 'humidity:'): "/g -e s/pressure:/"$(pickup_word "$DATA_LOCALE" 'pressure:'): "/g -e s/mbar/'hPa'/g -e s/wind:/"$(pickup_word "$DATA_LOCALE" 'wind:'): "/g | sed s/"`printf '\t'`"/'    '/g