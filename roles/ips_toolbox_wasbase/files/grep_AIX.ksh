#!/bin/ksh

awk -v direction="$1" -v offset="$2" -v pattern="$3" '

$0 ~ pattern {s=NR; _[NR]=$0; next}
{_[NR]=$0; next}

END{
        if( direction == "B" ){
                x=(s-offset)
                while( s >= x ){
                        print _[x]
                        x++
                }
        }
        if( direction == "A" ){
                x=(s+offset)
                while( s <= x ){
                        print _[s]
                        s++
                }
        }
}' $4

