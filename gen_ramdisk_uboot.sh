#!/bin/sh

dir=1

if [ ! -d $1 ];then
	dir=0
	echo "assuming the input file is gziped cpio image..."
fi

LOAD_ADDR="0x40800000"
ENTRY_ADDR="0x40800000"

outdir=`pwd`

if [ "$dir" -eq 0 ];then
	tmp="$1"
else
	tmp=`tempfile -p ramfs`
	cd $1
	find . | cpio -o -H newc | gzip -9 > "$tmp"
	cd "$outdir"
fi

rm -f "$outdir"/ramdisk-uboot.img

mkimage -A arm -O linux -T ramdisk -C none -a "$LOAD_ADDR" -e "$ENTRY_ADDR" -n ramdisk -d "$tmp" "$outdir"/ramdisk-uboot.img

ret=$?

if [ "$dir" -eq 1 ];then
	rm -f $tmp
fi

if [ "$ret" -ne 0 ];then
	exit 1
fi
