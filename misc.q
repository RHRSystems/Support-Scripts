/ These are various Q statements to query a kdb+ database

/if money >O then return *ITM", else if money <O then return "OTM", else return "ATM"
?[money>O;`ITM;?[money<0;`OTM;`ATM]]

/Command line to create output file:
echo "-1 csv O:\`:myqhostOOl:5911 \"10 sublist select start,host from stats\";" | $QHOME/l64/q > t.csv

/Get delayed trades:
`time xasc `err'PubTime`xtim xcols 0!update gtime xtim from select from Trades where
date=2Ol7.09.29,symbo1='CSGP.O,abs[qty]=200,trader=`JOESMITH,acct like "12345*"

/Login and last date for the last 35 days:
select max(date) by login from login where date within(.z.d-35;.2.d)

/Like sql group by
select count i by grp from tcTrades 
select first grp from trd where symbol = 'XLRN.O, brkr like "XXX*"
select by grp from trd where symbol = 'XLRN.0,brkr like "XXX*",tran = `S
select count i,prc by grp from trd where symbol = 'XLRN.O, brkr like "XHH*", prc>(avg;prc) fby grp

/Cast as text
select from Trades where acct=`$"12340-SMITH", sym like "*VXJ8*" 
select from bbinfo where BB_KEY=`$"CRY US Equity",not SYMBOL like "*.OTC"

select max prc from trd where symbol = 'XLRN.O, brkr like "XXX*", not prc = 37.444
select upper grp from trd where symbol = `XLRN.O, brkr like "XXX*"
select sum qty, prc, tran by trader from trd where symbol = 'XLRN.O, brkr like "XXX*"
l00 sublist select from Trades where trader =`JOE_SMITH, symbol like "CBSW*", Qty = 17880, exbr =`CIBC
select count i by trader,tradid from sometable where trad id in(1234;5678)
