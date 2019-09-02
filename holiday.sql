--View to show specific holidays upcoming for the next 2 weeks

DROP VIEW dbo.v_i_holidays
go
CREATE VIEW dbo.v_i_holidays
(hol_date,hol_exch_name,hol_holiday,hol_type,hol_market,hol_mkt_code,hol_curr)
AS select hol_date,exch_market_long_name, h.hol_comment,
  case RIGHT(exch_hol_conv1,1)
	when 'S' then 'Trading'
	when 'X' then 'Settlement'
	when 'B' then 'Bank'
	else 'Other'
  end,
  exch_market_name,exch_market_identifier,exch_currency
from shared..hts_holiday_detail d,
     shared..hts_holiday_list h,
     shared..hts_exchange e
where d.hol_id = h.hol_detail_id
and e.exch_hol_conv1 = d.hol_mnemonic
and hol_date=convert( int, convert(char(10), getdate(),112) )
union
/*Upcoming Exchange Holidays*/
select hol_date,exch_market_long_name, h.hol_comment,
  case RIGHT(exch_hol_conv1,1)
	when 'S' then 'Trading'
	when 'X' then 'Settlement'
	when 'B' then 'Bank'
	else'other'
  end,
  exch_market_name,exch_market_identifier,exch_currency
from shared..hts_holiday_detail d,
     shared..hts_holiday_list h,
     shared..hts_exchange e
where d.hol_id = h.hol_detail_id
and e.exch_hol_conv1 = d.hol_mnemonic
and hol_date between convert(int,convert(char(10),getdate(),112)) 
and convert(int,convert(char(10),dateadd(dd, l4,getdate()), 112))
go
grant select on v_i_holidays to met_ro_grp
go
grant select on v_i_holidays to supp_grp
go
