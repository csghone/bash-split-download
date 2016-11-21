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

filesize=$(curl -sI $url | gawk '/Content-Length/ { print $2 }' | tr -d $'\r')
filename=$(curl -sI $url | gawk -F= '/filename/ { print $2 }' | tr -d $'\r')

if [ -z $filename ]; then
	filename=$(echo $url | sed "s/.*\/\(.*\?\..*\?\)$/\1/")
	echo $filename
fi

echo "FILE NAME: $filename"
echo "FILE SIZE: $filesize"

numoftrunk=$(echo "scale = 0; $filesize / $TRUNKSIZE" | bc)

printf "NUMBER OF THREADS: %s" $numoftrunk

headbit=0
tailbit=$(expr $TRUNKSIZE - 1)
for i in `seq 1 $numoftrunk`
do
	file_append=`printf "%04d" $i`
	curl -s --range $headbit-$tailbit -o $filename.part$file_append $url &
	if [ "$tailbit" != "" ]; then
		headbit=$(expr $tailbit + 1)
	fi
	if [ "$i" -eq $(expr $numoftrunk - 1) ]; then
		tailbit=""
	else
		tailbit=$(expr $headbit + $TRUNKSIZE - 1)
	fi
done
