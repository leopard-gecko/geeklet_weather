# 週末の天気のスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=44
SUN_COLOR=41

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
detail=longPhrase

# 日付を表示する？（1 表示する、0 表示しない）
date_b=0

# 元データ取得（日曜日の場合は翌週の週末を取得する）
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
daily_data=`echo "$weather_data" | grep -e 'dailyForecast' | tr '{|}' '\n'`
sat_data=`echo "$daily_data" | grep -A3 $(date -v+$(expr 6 - $(date +%w))d +%Y-%m-%d) | tr ',' '\n' | tr -d '"'`
sun_data=`echo "$daily_data" | grep -A3 $(date -v+$(expr 7 - $(date +%w))d +%Y-%m-%d) | tr ',' '\n' | tr -d '"'`

# 土日の最高・最低気温と天気を表示
sat_hi=`echo "$sat_data" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
sat_lo=`echo "$sat_data" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`
sun_hi=`echo "$sun_data" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
sun_lo=`echo "$sun_data" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

printf "\033[0;${SAT_COLOR}mSaturday\033[0m"
[ $date_b -eq 1 ] && printf " ($(echo "$sat_data" | grep -m1 'date' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $sat_hi $sat_lo
echo "$sat_data" | grep -m1 "$detail" | awk -F: '{print $2}'

printf "\033[0;${SUN_COLOR}mSunday\033[0m"
[ $date_b -eq 1 ] && printf "   ($(echo "$sun_data" | grep -m1 'date' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $sun_hi $sun_lo
echo "$sun_data" | grep -m1 "$detail" | awk -F: '{print $2}'

# 週末の天気アイコン取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
icon_sat=`echo "$sat_data" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`
icon_sun=`echo "$sun_data" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sat"-l.png" | xargs curl --silent -o /tmp/weather_sat.png
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_sun"-l.png" | xargs curl --silent -o /tmp/weather_sun.png