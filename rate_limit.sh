TEMPFILE="$(mktemp $TMPDIR/git.XXXXXX)"
echo "Downloading api rate limit data to $TEMPFILE..."
if [ $# = 0 ]; then
	curl -o $TEMPFILE https://api.github.com/rate_limit >/dev/null 2>&1
else
	curl -o $TEMPFILE -u $1:$2 https://api.github.com/rate_limit >/dev/null 2>&1
fi

export TOTAL="`cat $TEMPFILE | jq .rate.limit`"
export USED="`cat $TEMPFILE | jq .rate.used`"
export FREE="`cat $TEMPFILE | jq .rate.remaining`"
export RESET="`cat $TEMPFILE | jq .rate.reset`"
echo "Removing $TEMPFILE.."
rm $TEMPFILE

printf "\033[0m"; echo "Total API REQUESTS: $TOTAL"; printf "\033[0m"
printf "\033[0m"; echo "Used API Requests: $USED"; printf "\033[0m"
if [ "$FREE" -gt 10 ]; then
	printf "\033[1m"; echo "Free API Requests: $FREE"; printf "\033[0m"
else
	printf "\033[1;31m"; echo "Free API Requests: $FREE"; printf "\033[0m"
fi
if [ "$FREE" -lt 30 ]; then
	printf "\033[0m"; echo "API will renew on `date --date="@$RESET" +%H:%M:%S`"; printf "\033[0m"
else
	printf "\033[1m"; echo "Enough requests avaliable!"; printf "\033[0m"
fi

if [ "$FREE" -eq 0 ]; then
	echo -e "\e[1;31mE:\e[0m API rate limit exhausted for REST api. You can renew it on `date --date="@$RESET"`."
	exit 1
fi
