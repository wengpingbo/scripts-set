#!/bin/sh
echo "Usage: sh repo_reset.sh [dir] [exclude dirs ...]"
echo "Warning: this script will reset all git repos recursively to HEAD!"
read -p "Are you sure? (N/y)" OK

[ "$OK" = "n" -o "$OK" = "N" -o "$OK" = "" ] && exit 1

FILTER_LIST=". .. .repo"
COUNT=0

check_entry(){
	for i in `echo $FILTER_LIST`
	do
		[ "$i" = "$1" ] && return 1
	done
	return 0
}

repo_reset(){
	pushd $1 > /dev/null
	((COUNT = COUNT + 1))
	echo "repo $COUNT: $1"
	git reset --hard HEAD
	popd > /dev/null
}

# list all file in current directory
reset_repo(){
	[ ! -d "$1" ] && return 1
	# trim the last '/', if it exists
	# variable cur must local, because of recursive function
	local cur=`echo $1 | sed -e 's/\(.*\)\/$/\1/'`
	if [ -d "$cur/.git" ];then
		repo_reset "$cur" 
		return 0
	fi

	for entry in `ls -a $cur`
	do
		check_entry $entry
		[ $? -eq 1 ] && continue
		[ -d "$cur/$entry" ] && reset_repo "$cur/$entry"
	done
}

# entry directory
target=$1
[ -z "$target" ] && target=`pwd`
shift

# append user specified list
while [ ! -z $1 ]
do
	FILTER_LIST=$FILTER_LIST" "$1
	shift
done

echo "Filter list: $FILTER_LIST"
reset_repo "$target"
echo
echo "Resetting $COUNT repos..."
