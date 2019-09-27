# 明日の天気のスクリプト

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# Tomorrowまたは曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
T_COLOR="40"

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
detail=longPhrase

# 何日後？
later=1

# 曜日を表示する？（1 表示する、0 表示しない）
dow=0
# 日付を表示する？（1 簡略表示、2 詳細表示、0 表示しない）
date_b=0

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
tomorrow_data=$(echo "$weather_data" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date -v+$(($later))d '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')
locale_data=$(echo "$weather_data" | grep -e 'pageLocale' |  tr '{|}' '\n' | sed s/',"'/\\$'\n'/g | tr -d '"')

# 明日の最高・最低気温と天気を表示
hi=`echo "$tomorrow_data" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
lo=`echo "$tomorrow_data" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`

[ $dow -eq 0 ] && printf "\033[0;${T_COLOR}m$(echo "$locale_data" | grep -m1 'tomorrow:' | awk -F: '{print $2}')\033[0m   "
[ $dow -eq 1 ] && printf "\033[0;${T_COLOR}m$(echo "$tomorrow_data" | grep -m1 'lDOW:' | awk -F: '{print $2}')\033[0m   "
[ $date_b -eq 1 ] && printf "\t($(echo "$tomorrow_data" | grep 'date:' | awk -F: '{print $2}'))"
[ $date_b -eq 2 ] && printf "\t($(echo "$tomorrow_data" | grep 'lDate:' | awk -F: '{print $2}'))"
echo
printf "%s/%s " $hi $lo
echo "$tomorrow_data" | grep -m1 "$detail" | awk -F: '{print $2}'

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
icon_data=`echo "$tomorrow_data" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`

echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"$icon_data"-l.png" | xargs curl --silent -o /tmp/weather_tomorrow.png