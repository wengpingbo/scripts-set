#!/bin/sh

if [ ! -d $1 ];then
	echo "please specify the ramdisk directory..."
	exit 1
fi

LOAD_ADDR="0x40800000"
ENTRY_ADDR="0x40800000"

outdir=`pwd`

cd $1 || exit 1

tmp=`tempfile -p ramfs`

find . | cpio -o -H newc | gzip -9 > "$tmp"

rm -f "$outdir"/ramdisk-uboot.img

mkimage -A arm -O linux -T ramdisk -C none -a "$LOAD_ADDR" -e "$ENTRY_ADDR" -n ramdisk -d "$tmp" "$outdir"/ramdisk-uboot.img

if [ $? -eq 0 ];then
	echo "generated ramdisk-uboot.img..."
	rm -f $tmp
else
	echo "ramdisk generated failed..."
	rm -f $tmp
	exit 1
fi
