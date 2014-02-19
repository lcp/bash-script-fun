#!/bin/sh
# Usage: dump_cert.sh <efi file> <output>
INPUT=$1

SEC_INFO=`objdump -h -j.vendor_cert -F $INPUT |grep .vendor_cert`
SEC_ADDR=0x`echo $SEC_INFO | cut -d ' ' -f 4`
SEC_OFFSET=0x`echo $SEC_INFO | cut -d ' ' -f 6`
CERT_PRIV=0x`nm $INPUT | grep -w vendor_cert_priv |cut -d ' ' -f 1`
CERT_PRIV_END=0x`nm $INPUT | grep -w vendor_cert_priv_end |cut -d ' ' -f 1`

OFFSET=$(($CERT_PRIV - $SEC_ADDR + $SEC_OFFSET))
SIZE=$(($CERT_PRIV_END - $CERT_PRIV))

CERT_SUM=`dd if=$INPUT skip=$OFFSET count=$SIZE bs=1 2>/dev/null | sha256sum -b | cut -d ' ' -f 1`
echo $CERT_SUM
