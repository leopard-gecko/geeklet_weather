# 現在時刻から７時間後までのスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# amとpmの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR=31
PM_COLOR=34

# 何時間後？ (時間をずらしたい場合はlaterの後の数字を書き換える)
later=0

# 元データ取得
my_hour=`date +%H`
curl_data1=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}`
curl_data2=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}"?day=1"`
curl_data=$(echo "$curl_data1" "$curl_data2"| grep -e 'hourlyForecast' | tr '{|}' '\n' | grep 'localTime' | sed -n $(expr 1 + $later),$(expr 8 + $later)p)

# ８時間分の時刻を取得（後で配列変数として使う。以下同様）
_IFS="$IFS";IFS="
"
current_time=(`echo "$curl_data" | awk -F\" '{print $10}'`) 
IFS="$_IFS"

# ８時間分の天気を取得
_IFS="$IFS";IFS="
"
current_weather=(`echo "$curl_data" | awk -F\" '{print $14}'`) 
IFS="$_IFS"

# ８時間分の天気アイコンのナンバーを取得
current_icon=(`echo "$curl_data" | sed -e 's/.*\"icon\":\([0-9]*\).*/\1/' | tr -cd '0123456789\n' | awk '{printf "%02d\n", $1}'`)

# 時刻を左揃え14桁で表示
_IFS="$IFS";IFS="
"
printf "%-14s" ${current_time[*]} | sed -e s/AM/`echo "\033[0;${AM_COLOR}mAM\033[0m"`/g -e s/PM/`echo "\033[0;${PM_COLOR}mPM\033[0m"`/g
IFS="$_IFS"
echo

# 天気を左揃え14桁かつ２段で表示
for (( i=0; i < ${#current_weather[@]}; ++i))
do
echo "${current_weather[$i]}" | awk '{printf "%-14s", $1}'
done
echo
for (( i=0; i < ${#current_weather[@]}; ++i))
do
echo "${current_weather[$i]}" | awk '{printf "%-14s", $2}'
done

# 天気アイコンを取得して保存（取得するアイコンのナンバーはゼロパディングする）
for (( i=0; i < ${#current_icon[@]}; ++i))
do
current_icon[$i]=`printf "%02d" ${current_icon[$i]}`
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${current_icon[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_`expr $i + $later`.png
done