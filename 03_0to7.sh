#!/bin/bash
LANG=ja_JP.UTF-8

# 時間単位のスクリプト その１

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR=31
PM_COLOR=34

# 何時間後？ (時間をずらしたい場合はlaterの後の数字を書き換える)
later=0

# 何時間分？
hour=8

# 表示桁数
my_strln=14

# 文字数取得用関数
mystrln() {
    local dn=0 mb=0
    for ((j = 0; j < $((${#1})); ++j))
    do
        [ `echo -n ${1:$j:1} | wc -c` -le 1 ] ; fd=$?
        dn=$(($dn+1+$fd))
        [ $dn -gt $2 ] && break
        mb=$(($mb+$fd))
    done
    printf -v $3 "%s" "`echo -n ${1:0:$j}`"
    printf -v $4 "%d" $(($mb+$2))
} 

# 元データ取得
weather_data0=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}`
weather_data1=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}"?day=1"`
hour_data=$(echo "$weather_data0" "$weather_data1"| grep 'hourlyForecast' | tr '{|}' '\n' | grep 'localTime' | sed -n $(expr 1 + $later),$(expr $hour + $later)p)

# 指定した時間分の時刻を取得（後で配列変数として使う。以下同様）
_IFS="$IFS";IFS="
"
current_time=(`echo "$hour_data" | awk -F'"localTime":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1`) 
IFS="$_IFS"

# 指定した時間分の天気を取得
_IFS="$IFS";IFS="
"
current_weather=(`echo "$hour_data" | awk -F'"phrase":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1`) 
IFS="$_IFS"

# 指定した時間分の天気アイコンのナンバーを取得してゼロパディング
current_icon=(`echo "$hour_data" | awk -F'"icon":' '{print $2}' | cut -d"," -f1 | awk '{printf "%02d\n", $1}'`)

# 時刻を左揃えの指定した桁数で表示
_IFS="$IFS";IFS="
"
for (( i=0; i < ${#current_time[@]}; ++i))
do
mystrln "$(echo "${current_time[$i]}")" $my_strln s1 s2
printf "%-*s" $s2 "$s1" | sed -e s/AM/`printf "\033[0;${AM_COLOR}mAM\033[0m"`/g -e s/PM/`printf "\033[0;${PM_COLOR}mPM\033[0m"`/g | tr -d '\n'
done
echo
IFS="$_IFS"

# 天気を左揃えの指定した桁数かつ3段で表示
for (( k=1; k < 4; ++k))
do
for (( i=0; i < ${#current_weather[@]}; ++i))
do
mystrln "$(echo "${current_weather[$i]}" | awk -v "knum=$k" '{printf "%s", $knum}')" $my_strln s1 s2
printf "%-*s" $s2 "$s1"
done
echo
done

# 天気アイコンを取得して保存
for (( i=0; i < ${#current_icon[@]}; ++i))
do
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${current_icon[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_`expr $i + $later`.png
done