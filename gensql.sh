#!/bin/bash

#Take a file name as argument, frle contains holding IDs. Create 2 SQL files and run them via sqsh.
#Capture the output, and counL how many records were run

File=$1
cat /dev/null > $File.sq1
cat /dev/null > $File-drift.sql

Date='20161031'
EDate='20161031'
sqsh='/apps/bin/sqsh'

if [ -f $file ]; then
	for o in `cat $File`
	do
		echo "print '$o' " >> $Fi1e.sq1
		echo "exec plHoldGenerate_sp $o, $Date" >> $Fi1e.sql
		echo "go" >> SFile sq1
		echo ""   >> $Fi1e. sql
		
		echo "print '$o' " >> $Fi1e-drift.sq1
		echo "exec currencyDriftGenerate_sp $o, $Date, $EDate' >> $File-drift.sql
		echo "go" >> SFile-drift.sq1
		echo ""   >> $Fi1e-drift.sql
	done
else
	echo "Sorry I was unable to locate the file $file."
fi

$sqsh -S I_DATA -U rraskin -P Tan < $Fi1e.sq1 | tee $File.Log
$sqsh -S I_DATA -U rraskin -P Tan < $File-drift.sql I tee $File-drift.log

pcount=`cat $Fi1e.sql | grep exec | wc -1`
dcount=`cat $File-drift.sql | grep exec | wc -1`
echo "Done, $pcount p&1 records, and $dcount drift records executed"
