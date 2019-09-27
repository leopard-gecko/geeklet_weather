# 週間天気のスクリプト

# 場所のURL （日本語表記にしたい場合は/en/を/ja/に書き換える）
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# 何日後から？
later=1
# 何日間？
days=7

# 日付を表示する？（1 表示する、0 表示しない）
date_b=1
# 曜日を表示する？（1 表示する、0 表示しない）
dow=1

# 天気の詳細（phrase 簡略表示、longPhrase 詳細表示）
detail=phrase

# 土曜日と日曜日の色 （30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルト）
SAT_COLOR=34
SUN_COLOR=31

# 元データ取得
weather_data=`curl -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent $weather_url`
for (( i = 0; i < $days; ++i ))
do
week_data[$i]=$(echo "$weather_data" | grep 'dailyForecast' | tr '{|}' '\n' | grep -A3 $(date -v+$(($later+$i))d '+%Y-%m-%d') | sed s/',"'/\\$'\n'/g | tr -d '"')
done

# 日付、曜日、最高・最低気温、天気を表示
for (( i = 0; i < $days; ++i ))
do
hi[$i]=`echo "${week_data[$i]}" | grep -A1 'day:' | grep 'dTemp' | awk -F: '{print $2}'`
lo[$i]=`echo "${week_data[$i]}" | grep -A1 'night:' | grep 'dTemp' | awk -F: '{print $2}'`
[ $date_b -eq 1 ] && printf "%5s " "$(echo "${week_data[$i]}" | grep 'date:' | awk -F: '{print $2}')"
[ $dow -eq 1 ] && printf "($(echo "${week_data[$i]}" | grep -m1 'dow:' | awk -F: '{print $2}' | sed -E s/Sat\|土/`printf "\033[0;${SAT_COLOR}m"`\&/ | sed -E s/Sun\|日/`printf "\033[0;${SUN_COLOR}m"`\&/ | sed -E 's/$/'`printf "\033[0m"`'/'))\t "
printf "%3s/%3s  " ${hi[$i]} ${lo[$i]}
echo "${week_data[$i]}" | grep -m1 "$detail" | awk -F: '{print $2}'
done

# 明日の天気アイコンのナンバーを取得して画像を保存（取得するアイコンのナンバーはゼロパディングする）
for (( i = 0; i < $days; ++i ))
do
icon_data[$i]=`echo "${week_data[$i]}" | grep -m1 'icon' | awk -F: '{printf "%02d",$2}'`
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/"${icon_data[$i]}"-l.png" | xargs curl --silent -o /tmp/weather_week_$(($i)).png
done