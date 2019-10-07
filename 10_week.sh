# 週間天気のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何日後から？
LATER=1
# 何日間？
DAYS=7

# 日付を表示する？（1 表示する、0 表示しない）
DATE_B=1
# 曜日を表示する？（1 表示する、0 表示しない）
DOW=1

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
DETAIL=phrase

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=34
SUN_COLOR=31

# データ整理用関数
pickup_day_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | grep -A3 $3 | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }
pickup_d_n_word() { echo "$1" | grep -A1 $2 | grep -m1 $3 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
for (( i = 0; i < $DAYS; ++i ))
do
DATA_WEEK[$i]=$(pickup_day_data "$WEATHER_DATA" 'dailyForecast' $(date -v+$(($LATER+$i))d '+%Y-%m-%d'))
done

# 日付、曜日、最高・最低気温、天気を表示
for (( i = 0; i < $DAYS; ++i ))
do
HI[$i]=$(pickup_d_n_word "${DATA_WEEK[$i]}" 'day:' 'dTemp')
LO[$i]=$(pickup_d_n_word "${DATA_WEEK[$i]}" 'night:' 'dTemp')
[ $DATE_B -eq 1 ] && printf "%5s " "$(pickup_word "${DATA_WEEK[$i]}" 'date:')"
if [ $DOW -eq 1 ]; then
  if [ $(date -v+$(($LATER+$i))d +%w) -eq 6 ]; then
    printf "\033[0;${SAT_COLOR}m"
  elif [ $(date -v+$(($LATER+$i))d +%w) -eq 0 ]; then
    printf "\033[0;${SUN_COLOR}m"
  fi
  printf "($(pickup_word "${DATA_WEEK[$i]}" 'dow:' | sed -E 's/$/'`printf "\033[0m"`'/'))\t "
fi
printf "%3s/%3s  " ${HI[$i]} ${LO[$i]}
pickup_word "${DATA_WEEK[$i]}" "$DETAIL"
done

# 天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
for (( i = 0; i < $DAYS; ++i ))
do
ICON_WEEK[$i]=$(printf "%02d" $(pickup_word "${DATA_WEEK[$i]}" 'icon'))
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${ICON_WEEK[$i]}"-l.png" | xargs curl --silent -o /tmp/weather_week_$(($i)).png
done

# 画像GeekletをRefleshする
osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT
