#!/bin/sh
#file name       :splitdownload.sh
#description     :Accelerate file download by splitting download job using curl
#author          :Antony Ho (http://antonyho.net/)
#date            :20131221
#usage           :./splitdownload.sh [FILE_URL]
#===============================================================================


# 100MB per trunk. Adjust it yourself
TRUNKSIZE=$(echo 100*1024*1024 | bc)

url=$1

filesize=$(curl -sI $url | awk '/Content-Length/ { print $2 }' | tr -d $'\r')
filename=$(curl -sI $url | awk -F= '/filename/ { print $2 }' | tr -d $'\r')

printf "FILE NAME: %s" $filename
echo "FILE SIZE: $filesize"

numoftrunk=$(echo "scale = 0; $filesize / $TRUNKSIZE" | bc)

printf "NUMBER OF THREADS: %s" $numoftrunk

headbit=0
tailbit=$(expr $TRUNKSIZE - 1)
for i in `seq 1 $numoftrunk`
do
	curl -s --range $headbit-$tailbit -o $filename.part$i $url &
	if [ "$tailbit" != "" ]; then
		headbit=$(expr $tailbit + 1)
	fi
	if [ "$i" -eq $(expr $numoftrunk - 1) ]; then
		tailbit=""
	else
		tailbit=$(expr $headbit + $TRUNKSIZE - 1)
	fi
done
