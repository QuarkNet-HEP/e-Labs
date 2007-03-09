#!/bin/bash

file=out-recent-1e3.txt

echo ---------------------
echo one microsecond level
echo zero bin

grep "e+00" $file | wc -l
grep "e-08" $file | wc -l
grep "e-07" $file | wc -l

echo bins 1 through 9 microseconds

for bin in 1 2 3 4 5 6 7 8 9
do
echo bin $bin counts `grep "e-06" $file | grep "diff ${bin}." | wc -l`

done

echo ---------------------
echo ten microsecond level
echo zero bin

grep "e+00" $file | wc -l
grep "e-08" $file | wc -l
grep "e-07" $file | wc -l
grep "e+06" $file | wc -l

echo bins 1 through 9 microseconds

for bin in 1 2 3 4 5 6 7 8 9
do
echo bin $bin counts `grep "e-05" $file | grep "diff ${bin}." | wc -l`

done
