#!/bin/bash

#
#Search through all directories and add a new line for KWf currency if it does not exist
#

ccymap='ccymap.csv'
location='/home/pkgs/configs'

for dir in 'ls $location'
do
	echo ""
	echo "Entering: Sdir"
	cd Slocation/$dir

	for f in 'ls'
	do
		if [$f == $ccymap]
		then
		  k='grep KWf $ccymap | wc -l'

		  if [ "$k" -ne "0" ]
		  then
			echo "Kwf is already in Sdir/$ccymap"
		  else
			echo "I am adding KWf to $dir/$ccymap"
			cp ccymap.csv ccymap.csv.bak
			sed '/KWD/a KWf,Kuwaiti fils,KWfUSD,KWp=,KWDUSD=R,KWD,KD,1000,0,100000' $ccymap > temp.csv
			mv temp.csv $ccymap
		  fi
		fi
    done
    cd Slocation
done
