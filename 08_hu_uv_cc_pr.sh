# 現在の湿度、紫外線、雲量、気圧などのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 取得するデータの整理
if [ $LINE_FEED -eq 1 ]; then lf='\n'; else lf='    '; fi

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(echo "$WEATHER_DATA" | grep -A2 '<div class="detail-item spaced-content">' | grep -e '<div>' -e '--' | tr -d '\t' | perl -pe 's/\n//g' | sed 's/<\/div><div>/: /g' | sed -e 's/<[^>]*>//g' | perl -pe 's/--/\n/g' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'))
IFS="$_IFS"

for (( i=0; i < 5; ++i))
do
echo ${DATA_CUR[i]} | perl -pe "s/\n/$lf/g"
done
echo
for (( i=5; i < $((${#DATA_CUR[@]}+1)); ++i))
do
echo ${DATA_CUR[i]} | perl -pe "s/\n/$lf/g"
done