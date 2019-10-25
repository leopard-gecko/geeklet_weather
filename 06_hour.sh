#!/bin/bash
# 時間単位のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/ja/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何時間分？
HOUR=24
# 何時間おき？
SKIP=2
# 何段？
COLUM=2
# 各段の間の改行数
NLF=5
# 表示桁数
MY_STRLN=15
# 見出しの文字数
MY_INDEX=9
# 気温、降水確率、雨量、風速、フレーズを表示する？（1 表示する、0 表示しない）
TEMP=1
PRECIP=1
RAIN=1
WIND=1
PHRASE=0
# 天気アイコンを取得する？（1 取得する、0 取得しない）
ICON_B=1
# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR='47;31'
PM_COLOR='47;34'
# 見出しの色
C_COLOR='0'

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

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }
pickup_array_word() { echo "$1" | awk -F"\"$2\":" '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1; }

# データ表示用関数
display_data() {
  mystrln "$(pickup_word "$DATA_LOCALE" "$1"):" $MY_INDEX S1 S2
  printf "\033[0;${C_COLOR}m%-*s\033[0m" $S2 "$S1"
  for i in $(seq 0 $SKIP $(($nt-1)))
  do
    mystrln "$(eval echo '${'$2'[$(($i+$n))]}')" $MY_STRLN S1 S2
    printf "%-*s" $S2 "$S1"
  done
  echo
}

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA0=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast})
WEATHER_DATA1=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast}"?day=2")
DATA_HOUR=$(echo "$WEATHER_DATA0" "$WEATHER_DATA1"| grep 'hourlyForecast' | perl -pe "s/},{/\n/g" | tr '[|]' '\n' | grep 'extended' | tr -d '{|}' | sed -n 1,$(echo $HOUR)p)
DATA_LOCALE=$(pickup_data "$WEATHER_DATA0" 'pageLocale')

# 指定した時間分の時刻・気温・降水確率・雨量・風速・天気を配列変数として取得
_IFS="$IFS";IFS="
"
CURRENT_TIME=($(pickup_array_word "$DATA_HOUR" 'localTime')) 
CURRENT_TEMP=($(pickup_array_word "$DATA_HOUR" 'temp' | sed -e 's/°//g'))
#CURRENT_TEMP=($(pickup_array_word "$DATA_HOUR" 'temp' | sed -e 's/°/℃/'))  # 等倍表示可能な日本語フォントで使用可能
CURRENT_PRECIP=($(pickup_array_word "$DATA_HOUR" 'precip')) 
CURRENT_RAIN=($(pickup_array_word "$DATA_HOUR" 'rain')) 
CURRENT_WIND=($(pickup_array_word "$DATA_HOUR" 'wind')) 
CURRENT_PHRASE=($(pickup_array_word "$DATA_HOUR" 'phrase')) 
IFS="$_IFS"

# 指定した時間分の天気アイコンのナンバーをゼロパディングし配列変数として取得
CURRENT_ICON=($(echo "$DATA_HOUR" | awk -F'"icon":' '{print $2}' | cut -d"," -f1 | awk '{printf "%02d\n", $1}'))

# 時刻・天気を表示
n=0
LNAP="/hi/\|/ar/\|/el/\|/ko/\|/ms/\|/bn/\|/ur/\|/kn/\|/te/\|/mr/\|/pa/\|/zh\|/en/"
L_AM="AM|पूर्वाह्न|π.μ.|오전|PG|পূর্বাহ্|ಪೂರ್ವಾಹ್ನ|म.पू.|ਪੂ.ਦੁ.|上午|ص|قبل دوپہر"
L_PM="PM|अपराह्|μ.μ.|오후|PTG|অপরাহ্ণ|ಅಪರಾಹ್ನ|PM|म.उ.|ਬਾ.ਦੁ.|下午|م|بعد دوپہر"
for (( l=0; l < $COLUM; ++l))
do
  for (( m=0; m < $NLF; ++m)); do echo; done
  [[ l -eq 0 ]] && nt=$(echo "scale=1; ($HOUR+0.9)/$COLUM" | bc | awk '{printf("%d",$1 + 0.5)}') || nt=$(($HOUR/$COLUM)) 
  # 時刻を左揃えの指定した桁数で表示
  printf "%*s" $MY_INDEX " "
  for i in $(seq 0 $SKIP $(($nt-1)))
  do
    mystrln "$(echo "${CURRENT_TIME[$(($i+$n))]}")" $MY_STRLN S1 S2
    if [ "$(echo $WEATHER_URL | grep $LNAP)" ]; then
      printf "%-*s" $S2 "$S1" | sed -E "/$L_AM/s/^/$(printf "\033[0;${AM_COLOR}m")/" | sed -E "/$L_PM/s/^/$(printf "\033[0;${PM_COLOR}m")/" | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
    else
      printf "%-*s" $S2 "$S1" | perl -pe 's/((?<![0-9])([0-9])(?![0-9])|0[0-9]|1[0-1])/'$(printf "\033[0;${AM_COLOR}m")'\1/' | sed -E 's/(1[2-9]|2[0-3])/'$(printf "\033[0;${PM_COLOR}m")'&/' | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
    fi
  done
  echo
  # 気温、降水確率、雨量、風向を左揃えの指定した桁数で表示
  [ $TEMP -eq 1 ] && display_data 'temp' 'CURRENT_TEMP'
  [ $PRECIP -eq 1 ] && display_data 'precip' 'CURRENT_PRECIP'
  [ $RAIN -eq 1 ] && display_data 'rain' 'CURRENT_RAIN'
  [ $WIND -eq 1 ] && display_data 'wind' 'CURRENT_WIND'
  # 天気を左揃えの指定した桁数かつ4段で表示
  if [ $PHRASE -eq 1 ]; then
    for (( k=1; k < 5; ++k))
    do
      printf "%-*s" $MY_INDEX " "
      for i in $(seq 0 $SKIP $(($nt-1)))
      do
        mystrln "$(echo "${CURRENT_PHRASE[$(($i+$n))]}" | awk -v "knum=$k" '{printf "%s", $knum}')" $MY_STRLN S1 S2
        printf "%-*s" $S2 "$S1"
      done
      echo
    done
  fi
  n=$(($n+$i+$SKIP))
done

# 天気アイコンを取得して保存
if [ $ICON_B -eq 1 ]; then
  for (( i=0; i < $(($HOUR/$SKIP+1)); ++i))
  do
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${CURRENT_ICON[$(($i*$SKIP))]}-m.png" | xargs curl --silent -o /tmp/weather_hour_$i.png
  done

fi
# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT
