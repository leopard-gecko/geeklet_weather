# 現在の湿度、紫外線、雲量、気圧などのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 改行表示（0 改行しない、1 改行する）
LINE_FEED=0

# 改行するか否かの表示用変数を定義
if [ $LINE_FEED -eq 1 ]; then lf='\n'; else lf='    '; fi
# 日本語表示の時は室内湿度が表示されないため調整
[ "$(echo $WEATHER_URL | grep 'com/ja/')" ] && F_JA=1 || F_JA=0

# 表示する項目（0 表示しない、1 表示する）
F_DISP[0]=1  #最大紫外線指数（Max UV Index）
F_DISP[1]=1  #風向（Wind）
F_DISP[2]=0  #最大瞬間風速（Gusts）
F_DISP[3]=1  #湿度（Humidity）
F_DISP[4]=0  #室内湿度（Indoor Humidity）
F_DISP[$((5-$F_JA))]=0  #露点（Dew Point）
F_DISP[$((6-$F_JA))]=1  #気圧（Pressure）
F_DISP[$((7-$F_JA))]=1  #雲量（Clour Cover）
F_DISP[$((8-$F_JA))]=0  #視界（Visibility）
F_DISP[$((9-$F_JA))]=0  #雲底高度（Cloud Ceiling）

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/current-weather})
_IFS="$IFS";IFS=$'\n'
DATA_CUR=($(echo "$WEATHER_DATA" | grep -A2 '<div class="detail-item spaced-content">' | grep -e '<div>' -e '--' | tr -d '\t' | perl -pe 's/\n//g' | sed 's/<\/div><div>/: /g' | sed -e 's/<[^>]*>//g' | perl -pe 's/--/\n/g' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }'))
IFS="$_IFS"

# 日中の表示があるか判定
[ $(echo "$WEATHER_DATA" | grep -c 'half-day-card-header') -eq 1 ] && F_N=1 || F_N=0

# 結果表示
for (( i=0; i < $((${#DATA_CUR[@]}+1-$F_JA)); ++i))
do
[ $(echo ${F_DISP[$((i+$F_N))]}) -eq 1 ] && echo ${DATA_CUR[i]} | perl -pe "s/\n/$lf/g"
done