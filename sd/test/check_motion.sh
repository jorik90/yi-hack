#!/bin/sh
# Every 20 seconds, check for files modified since we last checked
# if there is activity, it means motion was recently detected
# Since file writes begin immediately on motion detected, and don't end until approx 1min after motion ends, we only need to look for files modified very recently
# Relies on running mp4record process

cd /home/hd1/record/
touch last_motion_check
sleep 5 # since we /just/ created last_motion_check, the first check can return a false negative unless we wait a beat
while true; do
	echo "Checking for motion at `date`..."
	has_motion=$([ -z "`find . -type f -name "*.mp4*" -newer last_motion_check`" ] && echo "false" || echo "true")
	echo `date +%s` > last_motion_check
	motion_file=$(find . -type f -name "*.mp4" -mmin -1 | tail -1)
	echo "Motion file: $motion_file"
	echo $motion_file | sed "s/.\//record\//" > /home/hd1/test/http/motion
	motion_path=$(echo "$motion_file" |  sed 's/\.\/\(.*\)\/.*/\1/')
	if [ -n "$1" ]; then
		armed=$(ps | grep mp4record | grep -v grep -q && echo "true" || echo "false")
		notification="{\"armed\": $armed, \"motion\": $has_motion, \"last_motion_check\": `cat last_motion_check`, \"host\": \"`hostname`\"}"
		echo "$notification"
		/home/curl -H "Content-Type: application/json" --data "$notification" "$1" --silent --show-error --stderr - && echo "$1 notified"
	fi
	
	if [[ "$has_motion" == "true" ]] ; then
		echo "upload using webdav"
		# upload using webdav
		# warning! certificates are not validated
		curl() {
			LD_LIBRARY_PATH=/home/hd1/test/curl/libusr /home/hd1/test/curl/curl -k $@
		}
		# create dir
		curl --basic --user 'user:pass' -X MKCOL "https://url/remote.php/webdav/yicam/$motion_path"
		# upload
		curl --basic --user 'user:pass' -T "$motion_file" "https://url/remote.php/webdav/yicam/$motion_path/"
	fi

	sleep 20
done
