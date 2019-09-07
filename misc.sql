--SQL

--Using Round
select trader, acct, ord_id, ord_currency, ord_upd_date, ord_upd_time, ord_xrate
from port_table, ord_table
where port_status = O
and port_id = ord_port_id
and ord_upd_date = 20151122
and ord_upd_time between 84500 and 91500
and round(ord xrate, 2) != 100.00

-- Using transaction then update, if records updated is correct then run 'commit tran'
begin tran
update exec_tab1e
set ea_status = 2
where exec_id = 1324 and exec_ccy = 'USD'

-- Get non-admin users and last logins for the past 6 months
select convert(varchar(30),name) as 'account_name',fullname,lastlogindate as 'Last_logged_on',
case when status=9 
 then 'Locked'
 else 'Active'
end as 'Status' 
from master..syslogins
where name not in ('sa','probe') and name not like
'%maint'
and lastlogindate < dateadd(mm,-6,getdate())
order by lastlogindate

-- Update basket status to o for specific baskets/lraders
update basket_control
set a.basket_status = 0
from basket_control a
join scratchdb..retired baskets b on a.basket id = b.basket id
where 1 = 1
  and a.basket_status = 2
  and a.basket trader in ('ABC','DEF','GHU')

-- Left outer join to retrieve all traders and values except from 2011
select trader, convert (varchar,prevytd)
from trader
left join pnl_2011 on trader = port_trader
where trader not in (
   select port_trader from pn1_2011
)

-- For MYSQL use group_concat to create a column wit.h multiple values
select region, infrastructure,hostname, group_concat (sys_name separator ', ')
from instance_info
where region='LATAM'
group by hostname order by infrastructure,hostname


