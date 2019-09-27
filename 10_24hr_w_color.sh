# 時間単位のスクリプト(色付き、各国語対応)

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# AMとPMの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト
AM_COLOR=31
PM_COLOR=34

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
if [ "`echo $weather_url | grep '/hi/\|/ar/\|/el/\|/ko/\|/ms/\|/bn/\|/ur/\|/kn/\|/te/\|/mr/\|/pa/\|/zh\|/en/'`" ]; then
printf "%5s  \t" "${current_time[$i]}" | sed -E 's/AM|पूर्वाह्न|π.μ.|오전|PG|পূর্বাহ্|ಪೂರ್ವಾಹ್ನ|म.पू.|ਪੂ.ਦੁ.|上午|ص|قبل دوپہر/'`printf "\033[0;${AM_COLOR}m"`'&'`printf "\033[0m"`'/' | sed -E 's/PM|अपराह्|μ.μ.|오후|PTG|অপরাহ্ণ|ಅಪರಾಹ್ನ|PM|म.उ.|ਬਾ.ਦੁ.|下午|م|بعد دوپہر/'`printf "\033[0;${PM_COLOR}m"`'&'`printf "\033[0m"`'/' | tr -d '\n'
else
printf "%5s  \t" "${current_time[$i]}" | perl -pe 's/((?<![0-9])([0-9])(?![0-9])|0[0-9]|1[0-1])/\1'`printf "\033[0;${AM_COLOR}m"`'/' | sed -E 's/(1[2-9]|2[0-3])/&'`printf "\033[0;${PM_COLOR}m"`'/' | sed -E 's/$/'`printf "\033[0m"`'/' | tr -d '\n'
fi
echo "${current_weather[$i]}"
done
IFS="$_IFS"

# 天気アイコンを取得して保存
if [ $icon_b -eq 1 ]; then
for (( i=0; i < ${#current_icon[@]}; ++i))
do
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${current_icon[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_`expr $i + $later`.png
done
fi
