# 現在の湿度、紫外線、雲量、気圧などのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 表示する項目（0 表示しない、1 表示する）
F_DISP[0]=1  #紫外線指数（UV Index）
F_DISP[1]=1  #風向（Wind）
F_DISP[2]=1  #最大瞬間風速（Gusts）
F_DISP[3]=1  #湿度（Humidity）
F_DISP[4]=0  #露点（Dew Point）
F_DISP[5]=1  #気圧（Pressure）
F_DISP[6]=1  #雲量（Cloud Cover）
F_DISP[7]=0  #視界（Visibility）
F_DISP[8]=0  #雲底高度（Ceiling）

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 取得するデータの整理
if [ $LINE_FEED -eq 1 ]; then lf='\n'; else lf='    '; fi

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(echo "$WEATHER_DATA" | awk '/<div class=\"accordion-item-content accordion-item-content\">/,/<div class="arrow-wrap is-next">/' | grep -A1 '<p>' | grep -v '<p>' | grep -v '\-\-' | tr -d '\t' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'))
IFS="$_IFS"

for (( i=0; i < $((${#DATA_CUR[@]}+1)); ++i))
do
[[ F_DISP[i] -eq 1 ]] && echo ${DATA_CUR[i]} | perl -pe "s/\n/$lf/g"
done