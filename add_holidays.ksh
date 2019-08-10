#!/usr/bin/ksh
#
# Author:       RHR
# Purpose:      Update calendars in multiple Sybase databases in multiple servers.
#               First delete old records, then add new dates as holidays to Exchanges


SYBASE=/opt/sybase
THISPROG=cal2014.ksh
PS_RUN=/apphome/appnet
PASSWORD=this1isach0nge
USER=h7345qpcm
LOGFILE=$RUN/log/`date +"cal2014%Y%m%d_%T"`
MASTERSERVER=SYB_WHK1
PH_DATE_LIST="20140101 20140119 20140216 20140409 20140531 20140705 20140906 20141125 20141224"
BH_DATE_LIST="20141011 20141111"

##########
ServerList()
##########
{
echo "SYB_SRV1 SYB_SRV3"
}

##########
GetExch()
##########
{
$SYBASE/bin/isql -S $SERVER -U $USER -P $PASSWORD  -D $DB << EOF | tail +3
set nocount on
go
select EXCHANGE_ID
from   EXCHANGE
go
EOF
}

##########
DbList()
##########
{
$SYBASE/bin/isql -S $SERVER -U $USER -P $PASSWORD << EOF | tail +3
set nocount on
go
use master
go
if @@servername = "${MASTERSERVER}"
begin
select name from sysdatabases where name like "F_PROD_%" or name = "F_DATABASE"
end
else
begin
select name from sysdatabases where name like "F_PROD_%" and name != 'F_PROD_DABS'
end
go
EOF
}

##########
ExecPHSql()
##########
{
$SYBASE/bin/isql -S $SERVER -U $USER -P $PASSWORD -D $DB << EOF | tail +3
set nocount on
go
exec f_dbm_calendar_event @iSC_operation='M',
@iSC_admin_user='F_ASP_CLIENT',
@iSC_workstation='USNY-SUPDESK13',
@iSC_identifier_type='ID',
@exchange_id='${e}',
@date='${d}',
@event='PH'
go
EOF
}

##########
ExecBHSql()
##########
{
$SYBASE/bin/isql -S $SERVER -U $USER -P $PASSWORD -D $DB << EOF | tail +3
set nocount on
go
exec f_dbm_calendar_event @iSC_operation='M',
@iSC_admin_user='F_ASP_CLIENT',
@iSC_workstation='USNY-SUPDESK13',
@iSC_identifier_type='ID',
@exchange_id='${e}',
@date='${d}',
@event='BH'
go
EOF
}

##########
DelSql()
##########
{
$SYBASE/bin/isql -S $SERVER -U $USER -P $PASSWORD -D $DB << EOF | tail +3
set nocount on
go
DELETE FROM CALENDAR WHERE CONVERT(CHAR(4),DATE,112)<'2013'
go
EOF
}

##########
RunSql()
##########
{
for SERVER in `ServerList`
do
echo $SERVER
for DB in `DbList`
do
echo ""
echo $DB
echo "------------"
echo "PH_DATE_LIST"
echo "------------"
for e in `GetExch`
do
echo $e
for d in $PH_DATE_LIST
do
   DelSql
   echo $d
   ExecPHSql
done
done
done
done

for SERVER in `ServerList`
do
echo $SERVER
for DB in `DbList`
do
echo ""
echo $DB
echo "------------"
echo "BH_DATE_LIST"
echo "------------"
for e in `GetExch`
do
echo $e
for b in $BH_DATE_LIST
do
   echo $b
   ExecBHSql
done
done
done
done
}

#--------#
Main()
#--------#
{
echo "Start Time: `date`"
RunSql
echo "End Time : `date`"
}

Main | tee $LOGFILE
