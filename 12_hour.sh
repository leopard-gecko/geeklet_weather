# 時間単位のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR=31
PM_COLOR=34

# 何時間分？
HOUR=24
# 何時間おき？
SKIP=2
# 何段？
COLUM=2
# 各段の間の改行数
NLF=3
# 表示桁数
MY_STRLN=14
# 天気アイコンを取得する？（1 取得する、0 取得しない）
ICON_B=1

# 文字数取得用関数
mystrln() {
  local LANG=ja_JP.UTF-8
  local dn=0 mb=0
  for ((j = 0; j < $((${#1})); ++j))
  do
    [ $(/bin/echo -n ${1:$j:1} | wc -c) -le 1 ] ; fd=$?
    dn=$(($dn+1+$fd))
    [ $dn -gt $2 ] && break
    mb=$(($mb+$fd))
  done
  printf -v $3 "%s" "`/bin/echo -n ${1:0:$j}`"
  printf -v $4 "%d" $(($mb+$2))
} 

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA0=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast})
WEATHER_DATA1=$(curl -H "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast}"?day=2")
DATA_HOUR=$(echo "$WEATHER_DATA0" "$WEATHER_DATA1"| grep 'hourlyForecast' | tr '{|}' '\n' | grep 'localTime' | sed -n 1,$(echo $HOUR)p)

# 指定した時間分の時刻・天気を配列変数として取得
_IFS="$IFS";IFS="
"
CURRENT_TIME=($(echo "$DATA_HOUR" | awk -F'"localTime":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1)) 
CURRENT_WEATHER=($(echo "$DATA_HOUR" | awk -F'"phrase":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1)) 
IFS="$_IFS"

# 指定した時間分の天気アイコンのナンバーをゼロパディングし配列変数として取得
CURRENT_ICON=($(echo "$DATA_HOUR" | awk -F'"icon":' '{print $2}' | cut -d"," -f1 | awk '{printf "%02d\n", $1}'))

# 時刻を左揃えの指定した段数・桁数で表示
n=0
_IFS="$IFS";IFS="
"
for (( l=0; l < $COLUM; ++l))
do
  [[ l -eq 0 ]] && nt=$(echo "scale=1; ($HOUR+0.9)/$COLUM" | bc | awk '{printf("%d",$1 + 0.5)}') || nt=$(($HOUR/$COLUM)) 
  for i in $(seq 0 $SKIP $(($nt-1)))
  do
    mystrln "$(echo "${CURRENT_TIME[$(($i+$n))]}")" $MY_STRLN S1 S2
    if [ "$(echo $WEATHER_URL | grep '/hi/\|/ar/\|/el/\|/ko/\|/ms/\|/bn/\|/ur/\|/kn/\|/te/\|/mr/\|/pa/\|/zh\|/en/')" ]; then
      printf "%-*s" $S2 "$S1" | sed -E 's/AM|पूर्वाह्न|π.μ.|오전|PG|পূর্বাহ্|ಪೂರ್ವಾಹ್ನ|म.पू.|ਪੂ.ਦੁ.|上午|ص|قبل دوپہر/'$(printf "\033[0;${AM_COLOR}m")'&'$(printf "\033[0m")'/' | sed -E 's/PM|अपराह्|μ.μ.|오후|PTG|অপরাহ্ণ|ಅಪರಾಹ್ನ|PM|म.उ.|ਬਾ.ਦੁ.|下午|م|بعد دوپہر/'$(printf "\033[0;${PM_COLOR}m")'&'$(printf "\033[0m")'/' | tr -d '\n'
    else
      printf "%-*s" $S2 "$S1" | perl -pe 's/((?<![0-9])([0-9])(?![0-9])|0[0-9]|1[0-1])/\1'$(printf "\033[0;${AM_COLOR}m")'/' | sed -E 's/(1[2-9]|2[0-3])/&'$(printf "\033[0;${PM_COLOR}m")'/' | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
    fi
  done
  echo
  IFS="$_IFS"
  
  # 天気を左揃えの指定した桁数かつ4段で表示
  for (( k=1; k < 5; ++k))
  do
    for i in $(seq 0 $SKIP $(($nt-1)))
    do
      mystrln "$(echo "${CURRENT_WEATHER[$(($i+$n))]}" | awk -v "knum=$k" '{printf "%s", $knum}')" $MY_STRLN S1 S2
      printf "%-*s" $S2 "$S1"
    done
    echo
  done
  for (( m=0; m < $NLF; ++m)); do echo; done
  n=$(($n+$i+$SKIP))
done

# 天気アイコンを取得して保存
if [ $ICON_B -eq 1 ]; then
for (( i=0; i < $(($HOUR/$SKIP+1)); ++i))
do
  echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${CURRENT_ICON[$(($i*$SKIP))]}-s.png" | xargs curl --silent -o /tmp/weather_hour_$i.png
done
fi

# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
