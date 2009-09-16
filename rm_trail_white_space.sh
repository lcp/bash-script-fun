#!/bin/bash

string=$1
string=`echo $string|sed "s/^ *//" |sed "s/ *$//"`

echo $string
