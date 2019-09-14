#!/bin/bash

# This script renames an Fix adapter
# r. Renames direccory
# 2. Renames applicable files
# 3. Renames in cron

if [ $# -ne 3 ]
then
	echo "USAGE: $0 <FIXName> <New FIXName> <Target host>"
	exit l
fi

fix="$1"
newfix="$2"
tarhost="$3" # Target host
echo "`date`: Staring FIx $fix rename to Snewfix"
host=`hostname`
user=`whoami`
suphost="supp00l" #Support host
fix_hdir="/apps/fix" #FIX sym link directory
# Rename directories to new Adapter
fix_hdir=`ssh -nqx $suphost "ls -ltrd $fix_hdir/S{fix}" | awk -F'->' '{print $2}' | sed -e 's/^[]*//' -e 's/[ ]*$//'`
echo "Adapter home directory: $fix_hdir"
srchost=`echo gfix_hdir } awk -F'/' '{print $3}'`
localdir="~`echo $fix_hdir | awk -F"$srchost" '{print $2}'`"

echo "`date`: Rename relevant files on $tarhost"
ssh -nqx $tarhost "
	cp -Rp ~/$fix_hdir/Sfix ~/$fix_hdr/$newfix
	cd ~/$fix_hdir/$newfix/cfg
	mv "prod"$fix.cfg "prod"$newfix.cfg
	mv "prod"$fix.ini "prod"$newfix.ini
	mv "prod"$fix"password.cfg" mv "prod"$newfix"password.cfg"
	sed -i 's/$adn/$newfix/g "prod"$newfix.cfg
	sed -i 's/$adn/$newfix/g "prod"$newfix.ini
	cd ~/$fix_hdir/$newfixlog/store
	mv $fix.seqnums $newfix.seqnums
	rm -rf ~/$fix_hdir/$fix 	#remove old directory
"
echo "`date`: Renamed directory and files on $tarhost for $newfix"

# Adding cron entries to target host
echo "Modifying cron entries on $tarhost"
ssh -nqx $tarhost "
	crontab -l > /tmp/cron.$newadn.txt
	sed -i 's/$fix/$newfix/g' /tmp/cron.$newfix.txt
	crontab /tmp/cron.$newfix.txt
"
echo "`date`: Modified cron entries on $tarhost for $fix"

# Changing link
echo "Changing link from $fix to $newfix on $suphost"
ssh -nqx $suphost "
	cd /apps/fix
	unlink $fix
	ln -s /dat/$tarhost/apps/fix/$newfix $newfix
"

echo "`date`: Modified link on $suphost for $newfix"

# Remove fron register
echo "Removing $fix from register"
ssh -nqx $suphost "
	cd ~/apps/bin
	./register_remove_fix_prod.sh -ni $fix
"
echo "`date`: Removed $fix from register"
