# 降水確率、紫外線、降水量、風向などのスクリプト（日中）
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何日後？
LATER=0

# 表示する項目（0 表示しない、1 表示する）
F_DISP[0]=1  #降水確率（Precipitation）
F_DISP[1]=1  #最大紫外線指数（Max UV Index）
F_DISP[2]=0  #雷雨（Thunderstorms）
F_DISP[3]=1  #降水量（Precipitation）
F_DISP[4]=0  #降雨量（Rain）
F_DISP[5]=0  #降雪量（Snow）
F_DISP[6]=0  #みぞれの量（Ice）
F_DISP[7]=0  #降水時間（Hours of Precipitation）
F_DISP[8]=0  #降雨時間（Hours of Rain）
F_DISP[9]=1  #風向（Wind）
F_DISP[10]=1 #最大瞬間風速（Gusts）

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 取得するデータの整理
if [ $LINE_FEED -eq 1 ]; then lf='\n'; else lf='    '; fi

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast}?day=$(($LATER+1)))
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(echo "$WEATHER_DATA" | awk '/<div class=\"details-card card panel details allow-wrap\">/,/<div class=\"quarter-day-links\">/' | grep -A1 '<p>' | grep -v '<p>' | grep -v '\-\-' | tr -d '\t' | perl -C -MEncode -pe 's/&#x([0-9A-F]{2,4});/chr(hex($1))/ge' | sed -n 1,11p))
IFS="$_IFS"

for (( i=0; i < $((${#DATA_CUR[@]}+1)); ++i))
do
[[ F_DISP[i] -eq 1 ]] && echo ${DATA_CUR[i]} | perl -pe "s/\n/$lf/g"
done