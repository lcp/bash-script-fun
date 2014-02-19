#!/bin/bash

# http://stackoverflow.com/questions/4286469/how-to-have-bash-parse-a-csv-file

input=$1

while IFS=', ' read col1 col2
do
	echo "$col1 $col2"
done < $input
