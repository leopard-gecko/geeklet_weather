# Looking aheadのスクリプト
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# 場所のURL（日本語表記にしたい場合は/en/を/ja/に書き換える）
WEATHER_URL=${WEATHER_URL:='https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230'}

# データ整理用関数
pickup_data() { echo "$1" | grep -m1 $2 | tr '{|}' '\n' | perl -pe 's/,"/\n/g' | tr -d '"'; }
pickup_word() { echo "$1" | grep -m1 $2 | awk -F: '{print $2}'; }

# 元データ取得
USER_AGENT='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)'
WEATHER_DATA=$(curl -H "$USER_AGENT" --silent $WEATHER_URL)
DATA_LA=$(pickup_data "$WEATHER_DATA" 'localSummary')
DATA_LOCALE=$(pickup_data "$WEATHER_DATA" 'pageLocale')

# Looking aheadを取得して表示
echo $(pickup_word "$DATA_LOCALE" 'lookingAhead'): 
pickup_word "$DATA_LA" 'phrase'