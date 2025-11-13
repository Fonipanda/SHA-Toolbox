#!/usr/bin/ksh
dsmc q backup -date=3 /apps/sys/back/ -ina -detail -filesonly | tr '\n' ' ' | sed 's/Compressed/\
/g' | sed 's/Client-deduplicated: NO/\
/g' | sed 's/--- ----/\
/g' | grep mksysb | awk -F " " '{print $9}'

