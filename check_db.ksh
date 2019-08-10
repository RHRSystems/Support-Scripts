#!/usr/bin/ksh

# --------------------------------------------
# Author: Randy Raskin
# Job   : Run dbcc commands against Sybase databases
#       : Used for weekend maintenance
# --------------------------------------------

#
# Define Variables
# ----------------
#

if [ $1 = "SYB_NY1" ]
then
   password=h8password
elif [ $1 = "SYB_NY2" ]
then
   password=capassword
else
   echo "Unknown Server: $1"
   exit
fi

server=$1		                    ; export server
today=`date +%Y%m%d%H%M%S`      ; export today
username=sa	                    ; export username
master=master		                ; export master
sybsystemprocs=sybsystemprocs   ; export sybsystemprocs
local_dump_dir=/tmp             ; export local_dump_dir
top_dir=/export/home2/sybase/bin                  ; export top_dir
top_log_dir=/export/home/fda_imp/temp/randy/logs/ ; export top_log_dir

#
# Procudures
# ----------
#

#--------
get_dbs()
#--------
{
$top_dir/isql -U$username -P$password -S$server << EOF | tail +3
set nocount on
go
select name from master..sysdatabases where name like ("F_DAT%")
go
EOF
}

#-------------
dbcc_checkdb()
#-------------
{
$top_dir/isql -U$username -P$password -S$server << EOF > $top_log_dir/check_db.$db.log
dbcc checkdb($db)
go
EOF
}

#-------------
dbcc_traceon()
#-------------
{
$top_dir/isql -U$username -P$password -S$server << EOF
dbcc traceon(2512)
go
EOF
}

#--------------
dbcc_traceoff()
#--------------
{
$top_dir/isql -U$username -P$password -S$server << EOF
dbcc traceoff(2512)
go
EOF
}

#----------------
dbcc_checkalloc()
#----------------
{
$top_dir/isql -U$username -P$password -S$server << EOF >> $top_log_dir/check_db.$db.log
dbcc checkalloc($db)
go
EOF
}

#------------------
dbcc_checkcatalog()
#------------------
{
$top_dir/isql -U$username -P$password -S$server << EOF >> $top_log_dir/check_db.$db.log
dbcc checkcatalog($db)
go
EOF
}

#----------------
dbcc_tablealloc()
#----------------
{
$top_dir/isql -U$username -P$password -S$server << EOF >> $top_log_dir/check_db.$db.log
dbcc tablealloc(syslogs)
go
EOF
}

#-------------
calc_stripes()
#-------------
{
$top_dir/isql -U$username -P$password -S$server << EOF
use $db
go
set nocount on
select convert(varchar(2), SUM(size - unreservedpgs) / 512 / 1800 + 1)
FROM master.dbo.sysusages
WHERE db_name(dbid) = "$db"
go
EOF
}

#--------
dump_db()
#--------
{
NUMSTRIPES=`calc_stripes $db | sed '1,2d' | sed 's/ //g'`
SqlFile="$db.sql"

if [ -f $local_dump_dir/$server$db* ]
then
   rm $local_dump_dir/$server$db*
fi

if [ "$NUMSTRIPES" < "0" ]
then
    echo "script CalcDbStripes returned incorrect value:" $NUMSTRIPES
    exit 1
fi

echo "dump database $db to '$local_dump_dir/$server${db}_1of${NUMSTRIPES}_$today'" > $SqlFile

stripe=1
while [ "$stripe" -lt "$NUMSTRIPES" ]
do
   stripe=`expr $stripe + 1`
   echo "stripe on '$local_dump_dir/$server${db}_${stripe}of${NUMSTRIPES}_$today'" >> $SqlFile
done

echo "go"  >> $SqlFile

$top_dir/isql -U$username -P$password -S$server -i$SqlFile

compress $local_dump_dir/$server${db}*
}

#------------
dump_master()
#------------
{
if [ -f $local_dump_dir/${server}_${master}* ]
then
   rm $local_dump_dir/${server}_${master}*
fi

$top_dir/isql -U$username -P$password -S$server << EOF
dump database master to "$local_dump_dir/${server}_${master}_$today"
go
EOF

compress $local_dump_dir/${server}_${master}_$today
}

#--------------------
dump_sybsystemprocs()
#--------------------
{
if [ -f $local_dump_dir/${server}_${sybsystemprocs}* ]
then
   rm $local_dump_dir/${server}_${sybsystemprocs}*
fi

$top_dir/isql -U$username -P$password -S$server << EOF
dump database sybsystemprocs to "$local_dump_dir/${server}_${sybsystemprocs}_$today"
go
EOF

compress $local_dump_dir/${server}_${sybsystemprocs}_$today
}

#-------------
check_errors()
#-------------
{
msg_file=$top_log_dir/msg_file.dat
ErrorMsg=`cat $top_log_dir/check_db.$db.log | grep 'Msg'`  > $msg_file

if [ -s $msg_file ]
then
   #echo "To: randy.raskin@royalblue.com\n" > $msg_file
   echo "===================================================" >>  $msg_file
   echo "Check $top_log_dir/check_db.$db.log for Errors" >>  $msg_file
   echo "===================================================\n" >>  $msg_file
   mailx -s "Errors in DBCC for ${server} ${db}" randy.raskin@royalblue.com < $msg_file
else
   #echo "To: randy.raskin@royalblue.com\n" > $msg_file
   echo "==================================" >>  $msg_file
   echo "No Errors for ${server} ${db}" >>  $msg_file
   echo "==================================" >>  $msg_file
   mailx -s "Successful DBCC for ${server} ${db}" randy.raskin@royalblue.com < $msg_file
fi

rm $msg_file
}


#
# Entry Point
# -----------
#

if [ $# -lt 1 ]
then
    echo "Usage: servername"
    exit 1
fi

for db in `get_dbs`
do
   echo "\n--------------------------------------------------------"
   echo "Started work for ${server} ${db} at $today"
   echo "--------------------------------------------------------"

   dbcc_checkcatalog
   dbcc_checkdb
   dbcc_traceon
   dbcc_checkalloc
   dbcc_traceoff
   dbcc_tablealloc
   dump_db
   check_errors
done

dump_master
dump_sybsystemprocs
