# 時間単位のスクリプト(色なし)

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 何時間後？ (時間をずらしたい場合はlaterの後の数字を書き換える)
later=0

# 何時間分？
hour=24

# 天気アイコンを取得する？（1 取得する、0 取得しない）
icon_b=0

# 元データ取得
weather_data0=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}`
weather_data1=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}"?day=1"`
hour_data=$(echo "$weather_data0" "$weather_data1" | grep 'hourlyForecast' | tr '{|}' '\n' | grep 'localTime' | sed -n $(expr 1 + $later),$(expr $hour + $later)p)

# 指定された時間分の時刻を取得（後で配列変数として使う。以下同様）
_IFS="$IFS";IFS="
"
current_time=(`echo "$hour_data" | awk -F'"localTime":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1`) 
IFS="$_IFS"

# 指定された時間分の天気を取得
_IFS="$IFS";IFS="
"
current_weather=(`echo "$hour_data" | awk -F'"phrase":' '{print $2}' | cut -d"\"" -f2 | cut -d"\"" -f1`) 
IFS="$_IFS"

# 指定された時間分の天気アイコンのナンバーを取得してゼロパディング
current_icon=(`echo "$hour_data" | awk -F'"icon":' '{print $2}' | cut -d"," -f1 | awk '{printf "%02d\n", $1}'`)

# 時刻と天気を表示
_IFS="$IFS";IFS="
"
for (( i=0; i < ${#current_time[@]}; ++i))
do
printf "%6s \t%s\n" "${current_time[$i]}" "${current_weather[$i]}"
done
IFS="$_IFS"

# 天気アイコンを取得して保存
if [ $icon_b -eq 1 ]; then
for (( i=0; i < ${#current_icon[@]}; ++i))
do
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${current_icon[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_`expr $i + $later`.png
done
fi
