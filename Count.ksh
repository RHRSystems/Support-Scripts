#!/bin/ksh

# Author:   Randy Raskin
# Purpose:  Log into database and run SQL queries to get summary Trade and Order counts
#           for this year

GetMonths()
{
$SA_LOGIN -D F_ADAM << EOF
set nocount on
go
select distinct convert(char(6),CL_ENTERED_DATETIME,112) from TB_ORDER
go
EOF
}

GetOrders()
{
$SA_LOGIN -D F_ADAM << EOF
set nocount on
go
select CL_ENTERED_BY AS "Orders Entered By",count(*) AS "Count" from TB_ORDER o, TB_CURRENT_ORDER c
where convert(char(6),CL_ENTERED_DATETIME,112)='$f'
and o.CL_ORDER_ID = c.CL_ORDER_ID and o.CL_VERSION = c.CL_VERSION
group by CL_ENTERED_BY having count(*) > 1
order by 2
go
EOF
}

GetTrades()
{
$SA_LOGIN -D F_ADAM << EOF
set nocount on
go
select CL_ENTERED_BY AS "Trades Entered By",count(*) AS "Count" from TB_TRADE_SET t, TB_CURRENT_TRADE c
where substring(convert(CHAR,CL_TRADE_DATE),1,6) = '$f'
and t.CL_TRADE_SET_ID = c.CL_TRADE_SET_ID and t.CL_VERSION = c.CL_VERSION
group by CL_ENTERED_BY having count(*) > 1
order by 2
go
EOF
}

for f in `GetMonths`
do
        echo ""
        echo " $f"
        echo " ========"
        GetOrders
        echo ""
        GetTrades
done > AdOrTr.txt
