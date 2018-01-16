#!/bin/bash

sed -i -re 's/^(\s+print\s+)([[:print:]]+)/\1(\2)/g' $1
#              ^            ^                ^^^^
#              |            |                add the parentheses
#              +--group1    +--group2
# group1: search for 'print', including the whitespaces before and after 'print'
# group2: match all the printable characters
#
# Original: print content
# Result:   print (content)
