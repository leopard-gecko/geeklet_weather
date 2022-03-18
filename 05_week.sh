# 週間天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何日間？
NUM_L=7
# 何日後から？
AFTER=1
# 週末だけ表示？(0 週間表示、1 週末のみ表示)
F_WEEKEND=1
# 日付を表示する？（0 表示しない、1 表示する）
F_DATE=1
# 曜日を表示する？（0 表示しない、1 表示する）
F_DOW=1
# 温度・天気の詳細を表示する？（0 表示しない、1 表示する）
F_TEMP_PHRASE=1
# 降水確率を表示する？（0 表示しない、1 表示する）
F_PRECIP=1
# 各段の間の改行数
NLF=1
# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_SAT=44
COLOR_SUN=41
# 日付の色
COLOR_DATE=40;37
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# 設定
if
[ $F_WEEKEND -eq 1 ];then
NUM_L=2
AFTER=$(expr 6 - $(date +%w))
fi

# 元データ取得（日曜日の場合は翌週の週末を取得する）
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast})
DATA_WEEK_RAW=$(echo "$WEATHER_DATA" | grep -A20 'class="daily-forecast-card' | ruby -pe 'gsub(/&#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U") }' | tr -d '\t')
_IFS="$IFS";IFS='^'
DATA_WEEK=($(echo "$DATA_WEEK_RAW" | sed s/--/^/g))
IFS="$_IFS"
LOCALE_SAT=$(echo "$DATA_WEEK_RAW" | grep -A4 "?day=$(expr 6 - $(date +%w) + 1)\"" | grep 'dow date' | sed -e 's/<[^>]*>//g')
LOCALE_SUN=$(echo "$DATA_WEEK_RAW" | grep -A4 "?day=$(expr 7 - $(date +%w) + 1)\"" | grep 'dow date' | sed -e 's/<[^>]*>//g')
LOCALE_PRECIP='☂️'

# 日付、曜日、最高・最低気温、降水確率、天気を表示
for (( i = 0; i < $NUM_L; ++i ))
do
  HI[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep '<span class="high">' | sed -e 's/<[^>]*>//g')
  LO[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep '<span class="low">' | sed -e 's/<[^>]*>//g')
  DATE[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep 'sub date' | sed -e 's/<[^>]*>//g')
  DOW[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep 'dow date' | sed -e 's/<[^>]*>//g' | sed -E s/$LOCALE_SAT/$(printf "\033[0;${COLOR_SAT}m")\&/ | sed -E s/$LOCALE_SUN/$(printf "\033[0;${COLOR_SUN}m")\&/ | sed -E 's/$/'$(printf "\033[0m")'/')
  PRECIP[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep -A2 '<div class="precip">' | sed -n '3p')
  PHRASE[$i]=$(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep -A1 '<div class="phrase">' | grep -v '<div class="phrase">')
  [ $F_DATE -eq 1 ] && printf "\033[0;${COLOR_DATE}m%5s\033[0m\t" "${DATE[$i]}"
  [ $F_DOW -eq 1 ] && echo ${DOW[$i]}
  [ $F_TEMP_PHRASE -eq 1 ] && printf "%-5s%-6s  \t%4s\n" ${HI[$i]} "${LO[$i]}" "${PHRASE[$i]}"
  [ $F_PRECIP -eq 1 ] && echo $LOCALE_PRECIP: ${PRECIP[$i]}
  for (( m=0; m < $NLF; ++m)); do echo; done
done

# 天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
if [ $F_ICON -eq 1 ]; then
  for (( i = 0; i < $NUM_L; ++i ))
  do
  ICON_WEEK[$i]=$(printf "%02d" $(echo "${DATA_WEEK[$(expr $i + $AFTER)]}" | grep 'svg class="icon' | awk -F'weathericons/' '{print $2}' | cut -f 1 -d "." ))
  echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_WEEK[$i]}"-l.png" | xargs curl --silent -o /tmp/weather_week_$(($i)).png
  done
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
