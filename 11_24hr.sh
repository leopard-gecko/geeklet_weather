# 時間単位天気予報のスクリプト(色付き、多国語対応)
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何時間分？
NUM_L=25
# 何時間後から？
AFTER=0
# 何時間おき？
SKIP=1

# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR='31'
PM_COLOR='34'

# 天気アイコンを取得する？（1 取得する、0 取得しない）
ICON_B=0

# 日付を表示する？（1 表示する、0 表示しない）
DATE_B=0

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }
pickup_hour_word() { echo "$1" | awk -F"\"$2\":" '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1;}

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA0=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast})
WEATHER_DATA1=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast}"?day=2")
DATA_HOUR=$(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep 'hourlyForecast' | tr '{|}' '\n' | grep 'localTime' | sed -n $(expr 1 + $AFTER),$(expr $NUM_L + $AFTER)p)
DATA_LOCALE=$(pickup_data "$WEATHER_DATA0" 'pageLocale')
LOCAL_PRECIP=$(pickup_word "$DATA_LOCALE" 'precip:')

# 指定された時間分の時刻を取得（後で配列変数として使う。以下同様）
_IFS="$IFS";IFS="
"
CURRENT_TIME=($(pickup_hour_word "$DATA_HOUR" 'localTime'))
CURRENT_DATE=($(pickup_hour_word "$DATA_HOUR" 'localDate'))
IFS="$_IFS"

# 指定された時間分のデータを取得
_IFS="$IFS";IFS="
"
CURRENT_TEMP=($(pickup_hour_word "$DATA_HOUR" 'temp'))
CURRENT_PRECIP=($(pickup_hour_word "$DATA_HOUR" 'precip'))
CURRENT_WEATHER=($(pickup_hour_word "$DATA_HOUR" 'phrase'))
IFS="$_IFS"

# 時刻と天気を表示
_IFS="$IFS";IFS="
"
for i in $(seq 0 $SKIP $((${#CURRENT_TIME[@]}-1)))
do
  [ $DATE_B -eq 1 ] && printf "%5s\t" "${CURRENT_DATE[$i]}"
  if [ "$(echo $WEATHER_URL | grep '/hi/\|/ar/\|/el/\|/ko/\|/ms/\|/bn/\|/ur/\|/kn/\|/te/\|/mr/\|/pa/\|/zh\|/en/')" ]; then
      printf "%7s \t" "${CURRENT_TIME[$i]}" | sed -E 's/AM|पूर्वाह्न|π.μ.|오전|PG|পূর্বাহ্|ಪೂರ್ವಾಹ್ನ|म.पू.|ਪੂ.ਦੁ.|上午|ص|قبل دوپہر/'$(printf "\033[0;${AM_COLOR}m")'&'$(printf "\033[0m")'/' | sed -E 's/PM|अपराह्|μ.μ.|오후|PTG|অপরাহ্ণ|ಅಪರಾಹ್ನ|PM|म.उ.|ਬਾ.ਦੁ.|下午|م|بعد دوپہر/'$(printf "\033[0;${PM_COLOR}m")'&'$(printf "\033[0m")'/' | tr -d '\n'
  else
      printf "%7s\t" "${CURRENT_TIME[$i]}" | perl -pe 's/((?<![0-9])([0-9])(?![0-9])|0[0-9]|1[0-1])/\1'$(printf "\033[0;${AM_COLOR}m")'/' | sed -E 's/(1[2-9]|2[0-3])/&'$(printf "\033[0;${PM_COLOR}m")'/' | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
  fi
  echo -e " ${CURRENT_TEMP[$i]}\t${LOCAL_PRECIP}:$(printf "%4s" "${CURRENT_PRECIP[$i]}")\t ${CURRENT_WEATHER[$i]}"

  # 天気アイコンを取得して保存
  if [ $ICON_B -eq 1 ]; then
    ICON_CURRENT=($(echo "$DATA_HOUR" | awk -F'"icon":' '{print $2}' | cut -d"," -f1 | awk '{printf "%02d\n", $1}'))
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${ICON_CURRENT[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_l_$(($i/$SKIP)).png
  fi
done
IFS="$_IFS"

# 画像GeekletをRefleshする
[ $ICON_B -eq 1 ] && osascript <<EOT
    tell application "GeekTool Helper"
		tell image geeklets to refresh
	end tell
EOT
