#!/bin/bash
# 時間単位のスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# 何時間分？
NUM_HOUR=24
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
F_TEMP=1
F_PRECIP=1
F_RAIN=1
F_WIND=1
F_PHRASE=1
# 天気アイコンを取得する？（1 取得する、0 取得しない）
F_ICON=1
# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
COLOR_AM='47;31;1'
COLOR_PM='47;34;1'
# 見出しの色
COLOR_CP='0'
# 天気フレーズの色
COLOR_PHRASE='3'
# 日本語対応の等幅フォント？（1 対応【Osaka-等幅、Ricty、Myrica Mなど】、0 非対応【Andale Mono、Courier、Menlo、Monacoなど】）
F_JFNT=1

# 設定
[ $F_JFNT -eq 1 ] && JFNT='℃' || JFNT='°'

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

# データ表示用関数
display_data() {
  mystr=$(echo "$1" | perl -C -MEncode -pe 's/&#x([0-9A-F]{2,4});/chr(hex($1))/ge')
  mystrln "$mystr" $MY_INDEX S1 S2
  printf "\033[0;${COLOR_CP}m%-*s\033[0m" $S2 "$S1"
  for i in $(seq 0 $SKIP $(($nt-1)))
  do
    mystrln "$(eval echo '${'$2'[$(($i+$n))]}' | perl -C -MEncode -pe 's/&#x([0-9A-F]{2,4});/chr(hex($1))/ge')" $MY_STRLN S1 S2
    printf "%-*s" $S2 "$S1"
  done
  echo
}

# 元データ取得
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA0=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast})
WEATHER_DATA1=$(curl -A "$USER_AGENT" --silent ${WEATHER_URL/weather-forecast/hourly-weather-forecast}"?day=2")

# 表示する項目名を取得
LOCALE_TEMP=' '
LOCALE_PRECIP=''

if [ "$(echo $WEATHER_URL | grep 'com/en/')" ]; then
	LOCALE_RAIN="Rain"
	LOCALE_WIND="Wind"
elif [ "$(echo $WEATHER_URL | grep 'com/ja/')" ]; then
	LOCALE_RAIN="&#x96E8;"
	LOCALE_WIND="&#x98A8;&#x5411;"
else
	F_RAIN=0
	F_WIND=0
fi

# 時刻・気温・降水確率・雨量・風速・天気を配列変数として取得
_IFS="$IFS";IFS=$'\n'
HOUR_TIME=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep -A1 'class="date"' | grep 'span' | sed -e 's/<span>//g' -e 's/<\/span>//g'))
HOUR_TEMP=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep -A1 '<div class="temp metric">' | grep -v '<div class="temp metric">' | grep -v '\-\-' | cut -d\& -f1 | sed -E s/$/$JFNT/))
HOUR_PRECIP=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep -A2 '<div class="precip">' | grep \% | grep -v '\-\-'))
HOUR_RAIN=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep -e '<div class="hourly-content-container">' -e ">$LOCALE_RAIN<" | tr -d '\t' | tr -d '\n' | perl -pe 's/<div class="hourly-content-container">/\n /g' | sed '1d' | sed "s/$LOCALE_RAIN//g" | sed -e 's/<[^>]*>//g'))
HOUR_WIND=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep "$LOCALE_WIND<" | sed -e 's/<[^>]*>//g' | tr -d '\t' | sed -e "s/$LOCALE_WIND//g"))
HOUR_PHRASE=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep -A1 '<span class="phrase">' | grep -v '<span class="phrase">' | grep -v '\-\-'))
IFS="$_IFS"

# 天気アイコンのナンバーをゼロパディングし配列変数として取得
HOUR_ICON=($(echo "$WEATHER_DATA0" "$WEATHER_DATA1" | grep 'class="weather-icon icon"' | awk -F'/images/weathericons/' '{print $2}' | cut -d. -f1 | awk '{printf "%02d\n", $1}' ))

# 時刻・天気を表示
n=0
LNAP="/hi/\|/ar/\|/el/\|/ko/\|/ms/\|/bn/\|/ur/\|/kn/\|/te/\|/mr/\|/pa/\|/zh\|/en/"
L_AM="AM|पूर्वाह्न|π.μ.|오전|PG|পূর্বাহ্|ಪೂರ್ವಾಹ್ನ|म.पू.|ਪੂ.ਦੁ.|上午|ص|قبل دوپہر"
L_PM="PM|अपराह्|μ.μ.|오후|PTG|অপরাহ্ণ|ಅಪರಾಹ್ನ|PM|म.उ.|ਬਾ.ਦੁ.|下午|م|بعد دوپہر"
for (( l=0; l < $COLUM; ++l))
do
  for (( m=0; m < $NLF; ++m)); do echo; done
  [[ l -eq 0 ]] && nt=$(echo "scale=1; ($NUM_HOUR+0.9)/$COLUM" | bc | awk '{printf("%d",$1 + 0.5)}') || nt=$(($NUM_HOUR/$COLUM)) 
  # 時刻を左揃えの指定した桁数で表示
  printf "%*s" $MY_INDEX " "
  for i in $(seq 0 $SKIP $(($nt-1)))
  do
    MY_TIME=$(echo "${HOUR_TIME[$(($i+$n))]}" | perl -C -MEncode -pe 's/&#x([0-9A-F]{2,4});/chr(hex($1))/ge')
    mystrln "$MY_TIME" $MY_STRLN S1 S2
    if [ "$(echo $WEATHER_URL | grep $LNAP)" ]; then
      printf "%-*s" $S2 "$S1" | sed -E "/$L_AM/s/^/$(printf "\033[0;${COLOR_AM}m")/" | sed -E "/$L_PM/s/^/$(printf "\033[0;${COLOR_PM}m")/" | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
    else
      printf "%-*s" $S2 "$S1" | perl -pe 's/((?<![0-9])([0-9])(?![0-9])|0[0-9]|1[0-1])/'$(printf "\033[0;${COLOR_AM}m")'\1/' | sed -E 's/(1[2-9]|2[0-3])/'$(printf "\033[0;${COLOR_PM}m")'&/' | sed -E 's/$/'$(printf "\033[0m")'/' | tr -d '\n'
    fi
  done
  echo
  # 気温、降水確率、雨量、風向を左揃えの指定した桁数で表示
  [ $F_TEMP -eq 1 ] && display_data "$LOCALE_TEMP" 'HOUR_TEMP'
  [ $F_PRECIP -eq 1 ] && display_data "$LOCALE_PRECIP" 'HOUR_PRECIP'
  [ $F_RAIN -eq 1 ] && display_data "$LOCALE_RAIN" 'HOUR_RAIN'
  [ $F_WIND -eq 1 ] && display_data "$LOCALE_WIND" 'HOUR_WIND'
  # 天気を左揃えの指定した桁数かつ4段で表示
  if [ $F_PHRASE -eq 1 ]; then
    for (( k=1; k < 5; ++k))
    do
      printf "%-*s" $MY_INDEX " "
      for i in $(seq 0 $SKIP $(($nt-1)))
      do
        MY_PHRASE=$(echo "${HOUR_PHRASE[$(($i+$n))]}" | perl -C -MEncode -pe 's/&#x([0-9A-F]{2,4});/chr(hex($1))/ge')
        mystrln "$(echo "$MY_PHRASE" | awk -v "knum=$k" '{printf "%s", $knum}')" $MY_STRLN S1 S2
        printf "\033[0;${COLOR_PHRASE}m%-*s\033[0m" $S2 "$S1"
      done
      echo
    done
  fi
  n=$(($n+$i+$SKIP))
done

# 天気アイコンを取得して保存
if [ $F_ICON -eq 1 ]; then
  for (( i=0; i < $(($NUM_HOUR/$SKIP+1)); ++i))
  do
    echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${HOUR_ICON[$(($i*$SKIP))]}-m.png" | xargs curl --silent -o /tmp/weather_hour_$i.png
  done

fi
# 画像GeekletをRefleshする
osascript <<EOT
  tell application "GeekTool Helper"
    tell image geeklets to refresh
  end tell
EOT