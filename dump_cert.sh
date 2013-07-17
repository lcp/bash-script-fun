#!/bin/sh
# Usage: dump_cert.sh <efi file> <output>
INPUT=$1
OUTPUT=$2

SEC_INFO=`objdump -h -j.data -F $INPUT |grep .data`
SEC_ADDR=0x`echo $SEC_INFO | cut -d ' ' -f 4`
SEC_OFFSET=0x`echo $SEC_INFO | cut -d ' ' -f 6`
CERT_ADDR=0x`nm $INPUT | grep -w vendor_cert |cut -d ' ' -f 1`
SIZE_ADDR=0x`nm $INPUT | grep -w vendor_cert_size |cut -d ' ' -f 1`
CERT_OFFSET=$(($CERT_ADDR - $SEC_ADDR + $SEC_OFFSET))
SIZE_OFFSET=$(($SIZE_ADDR - $SEC_ADDR + $SEC_OFFSET))
SIZE=`od -An -j $SIZE_OFFSET -N 4 -t d $INPUT | tr -d ' '`

echo "dd if=$INPUT of=$OUTPUT skip=$CERT_OFFSET count=$SIZE bs=1"
dd if=$INPUT of=$OUTPUT skip=$CERT_OFFSET count=$SIZE bs=1
