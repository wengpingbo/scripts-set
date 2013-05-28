#!/bin/bash
#
#rename file.jpg with num.jpg
#date:2012/12/12 
#first use in java applet
#email:wengpingbo@gmail.com
#
read -p "please input the directory you want to rename:" dir
i="1"
cd "$dir"
for name in `ls`
do
	mv "$name" "$i"`echo ".jpg"`
	((i++))
done
echo "name changed successful"
