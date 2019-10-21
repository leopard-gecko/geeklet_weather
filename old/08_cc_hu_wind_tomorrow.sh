# 明日の紫外線、雲量、風速・風向き、降水確率のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL （日本語表記にしたい場合は/de/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

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

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast}?day=$(($LATER+1)))
DATA_TOMORROW=$(pickup_data "$WEATHER_DATA" 'today' | awk '/date:/,/night:/') 
DATA_LOCALE=$(echo "$WEATHER_DATA" | grep -e 'pageLocale' |  tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 明日の雲量、湿度、風速・風向きを取得して表示
echo "$DATA_TOMORROW" | grep -A2 $(echo $ui) | tr '\n' ':' | awk -F: -v uvi="$(pickup_word "$DATA_LOCALE" 'maxUV:')" '{print uvi": "$6,"("$4")"}' | sed "s/$/    /g" | tr '\n' "$(echo $lf)"
echo "$DATA_TOMORROW" | grep ''$(echo $cc$wi$pr)'' | sed "s/$/    /g" | tr '\n' "$(echo $lf)" | sed -e s/cc:/"$(pickup_word "$DATA_LOCALE" 'cloudCover:'): "/g -e s/wind:/"$(pickup_word "$DATA_LOCALE" 'wind:'): "/g -e s/precip:/"$(pickup_word "$DATA_LOCALE" 'precip:'): "/g
