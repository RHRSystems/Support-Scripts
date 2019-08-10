#!/bin/ksh

# -- Author: Randy Raskin
# -- BCP table out to back up, then delete specific records from table
# --

bcp F_CLIENT..ALT_COUNTERPARTY_ID out F_CLIENT..ALT_COUNTERPARTY_ID.bcp \
    -c -Usa -P f0r -SSYB_WHK_REPORT77
bcp F_CLIENT..COUNTERPARTY out F_CLIENT..COUNTERPARTY.bcp \
    -c -Usa -P f0 -SSYB_REPORT77
bcp F_CLIENT..STB_CLIENT_PROFILE out F_CLIENT..STB_CLIENT_PROFILE.bcp \
    -c -Usa -P f0r -SSYB_REPORT77

# -- (2)
# -- This will recreate a file of sql commands out of the csv file
# -- Then we isql the sql file
# --

GetCpty()
{
isql -U sa -P f0r -S SYB_REPORT77 -D F_CLIENT << EOF | tail +3
SET NOCOUNT ON
GO
SELECT COUNTERPARTY_ID from COUNTERPARTY
WHERE  COUNTERPARTY_ID like '143%'
OR     COUNTERPARTY_ID like '743%'
OR     COUNTERPARTY_ID like '144%'
GO
EOF
}

cat /dev/null > del.sql

for f in `GetCpty`
do
   echo "$f..."
   echo  "exec fda_dbm_counterparty"              >> del.sql
   echo  "@iSC_operation               = 'D',"    >> del.sql
   echo  "@iSC_admin_user              = 'ME',"   >> del.sql
   echo  "@iSC_workstation             = 'MINE'," >> del.sql
   echo  "@read_date                   =  NULL,"  >> del.sql
   echo  "@counterparty_id             = '$f'"    >> del.sql
   echo  "go"                                     >> del.sql
   echo  ""                                       >> del.sql
done

isql -Usa -P f0r -SSYB_REPORT77 -DF_CLIENT < del.sql | tee del.log
