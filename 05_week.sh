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
F_DATE=0
# 曜日を表示する？（0 表示しない、1 簡略表示、2 詳細表示）
F_DOW=2
# 温度・降水確率を表示する？（0 表示しない、1 表示する）
F_TEMP_PRECIP=1
# 天気の詳細（0 表示しない、1 簡略表示、2 詳細表示）
F_PHRASE=1
# 各段の間の改行数
NLF=1
# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
COLOR_SAT=44
COLOR_SUN=41
# 天気アイコンを取得する？（0 取得しない、1 取得する）
F_ICON=1

# 設定
if
[ $F_WEEKEND -eq 1 ];then
NUM_L=2
AFTER=$(expr 6 - $(date +%w))
fi
[ $F_DOW -eq 1 ] && MY_DOW='dow:'
[ $F_DOW -eq 2 ] && MY_DOW='lDOW:'
[ $F_PHRASE -eq 1 ] && MY_PHRASE='phrase'
[ $F_PHRASE -eq 2 ] && MY_PHRASE='longPhrase'

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_d_n_word() { echo "$1" | grep -A7 $2 | grep -m1 $3 | awk -F: '{print $2}'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得（日曜日の場合は翌週の週末を取得する）
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/daily-weather-forecast})
for (( i = 0; i < $NUM_L; ++i ))
do
  DATA_WEEK[$i]=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(($AFTER+$i))d '+%Y-%m-%d'))
done
LOCALE_SAT=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(expr 6 - $(date +%w))d +%Y-%m-%d) | grep $MY_DOW | awk -F: '{print $2}')
LOCALE_SUN=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(expr 7 - $(date +%w))d +%Y-%m-%d) | grep $MY_DOW | awk -F: '{print $2}')

# 日付、曜日、最高・最低気温、降水確率、天気を表示
for (( i = 0; i < $NUM_L; ++i ))
do
  HI[$i]=$(pickup_d_n_word "${DATA_WEEK[$i]}" 'day:' 'dTemp')
  LO[$i]=$(pickup_d_n_word "${DATA_WEEK[$i]}" 'night:' 'dTemp')
  [ $F_DATE -eq 1 ] && printf "%5s\t" "$(pickup_word "${DATA_WEEK[$i]}" 'date:')"
  [[ $F_DOW =~ 1|2 ]] && printf "$(pickup_word "${DATA_WEEK[$i]}" $MY_DOW | sed -E s/$LOCALE_SAT/$(printf "\033[0;${COLOR_SAT}m")\&/ | sed -E s/$LOCALE_SUN/$(printf "\033[0;${COLOR_SUN}m")\&/ | sed -E 's/$/'$(printf "\033[0m")'/')\n"
  [ $F_TEMP_PRECIP -eq 1 ] && printf "%-5s/%-5s\t☂️ :%4s\n" ${HI[$i]} ${LO[$i]} $(pickup_word "${DATA_WEEK[$i]}" 'precip')
  [[ $F_PHRASE =~ 1|2 ]] && pickup_word "${DATA_WEEK[$i]}" "$MY_PHRASE"
  for (( m=0; m < $NLF; ++m)); do echo; done
done

# 天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
if [ $F_ICON -eq 1 ]; then
  for (( i = 0; i < $NUM_L; ++i ))
  do
  ICON_WEEK[$i]=$(printf "%02d" $(pickup_word "${DATA_WEEK[$i]}" 'icon'))
  echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_WEEK[$i]}"-l.png" | xargs curl --silent -o /tmp/weather_week_$(($i)).png
  done
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
