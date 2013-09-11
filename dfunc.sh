#!/bin/sh
#file: dfunc.h

########################
# Global function
########################
error()
{
	echo "$1"
	exit 1
}

show_usage()
{
	echo "This is a script to disassemble specified function in a shared library."
	echo "Author: WEN Pingbo <wengpingbo@gmail.com>"
	echo "Date: 2013/09/11"
	echo "Usage: sh dfunc [-f function name] [-l library path] [-c shift number]"
	echo "Note: sometimes, you should using -c to disassemble more bytes because of alignments."
}

########################
# Global function
########################

# default value
func_name="fexecve"
target="/lib/x86_64-linux-gnu/libc-2.15.so"
caliberation="0"

if [ -n "$1" ] && [ "$1" == "-h" ];then
	show_usage
	exit 0
fi

# parse the argument
arg_ok="0"
while [ -n "$1" ]
do
if [ "$1" == "-f" ];then
	shift
	arg_ok="1"
	if [ -n "$1" ];then
	   	func_name="$1"
		shift
	fi
fi

if [ "$1" == "-l" ];then
	shift
	arg_ok="1"
	if [ -n "$1" ];then
		target="$1"
		shift
	fi
fi

if [ "$1" == "-c" ];then
	shift
	arg_ok="1"
	if [ -n "$1" ];then
		caliberation="$1"
		shift
	fi
fi

[ "$arg_ok" == "0" ] && shift
arg_ok="0"
done

offset=`readelf -s "$target" | grep " "$func_name"" | awk '{print $3}'`

[ -z "$offset" ] && error ""$func_name" not found..."

offset=$(($offset + $caliberation))

# convert dec to hex
offset=`echo "obase=16; ibase=10; "$offset"" | bc`

begin=`nm -D "$target" | grep " "$func_name"$" | awk '{print $1}'`
end=`echo "obase=16; ibase=16; ${begin^^} + ${offset^^}" | bc`

objdump -d --start-address=0x"$begin" --stop-address=0x"$end" "$target"
