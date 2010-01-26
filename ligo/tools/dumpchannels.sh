#!/bin/bash

dump() {
	F=`find $1/$2 -name '*.gwf' | head -n 1`
	if [ "X$F" != "X" ]; then
		FrDump -i $F -d 4 >> channels.info
	else
		echo "Skipping $1/$2"
	fi
}

rm -f channels.info
dump "second-trend" "LHO"
dump "second-trend" "LLO"
dump "minute-trend" "LHO"
dump "minute-trend" "LLO"



