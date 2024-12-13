--stored procedure to extract trades for export.  Include header and trailer records.
--Randy Raskin

USE [positions]
GO

create or alter PROCEDURE [dbo].[proc_send_trades] (@rundate char(10) = null)
AS

drop table if exists #header 
drop table if exists #trailer
drop table if exists #results

SELECT
	CONVERT(varchar(50), ta.order_id) as tradeid
	,case ta.transaction_status
		when 'CONFIRMED' then 'NEW'
		when 'CANCELLED' then 'CANCEL'
	end as action
	,CONVERT(varchar(12),ta.trade_date,101) as trade_date
	,CONVERT(varchar(12),ta.settlement_date,101) as settlement_date
	,REPLACE(right(fa.fcm_account_code,9),'-','') as account 
	,'SWAP' as method
	,left(ta.transaction_type,1) as side 
	,isnull(s.bb_symbol_code, s.ric_code) as security 
	,case s.bb_global_id when null then 'R' else 'B' end as sec_id
	,ta.transaction_qty as quantity 
	,cast(round(ta.transaction_price,6) as decimal(23,6) as price
	,ta.broker_code as exec_brkr
	,ta.trans_settle_currency_code as currency
	,1 as exchg_rate
into #results 
from positions.dbo.trades_audits ta with (nolock)
	join investment_ref.dbo.v_investment)sec s with (nolock) on s.security_id = ta.security_id
	join portfolio.dbo.fcm_account fa with (nolock) on ta.fund_code = fa.fund_code
		and fa.custodian_account_code = 'ZBCD'

where 1=1
	and ta.transaction_qty > 0
	and s.security_type_code in ('CFD','INDX','EQSWAP')
	and convert(char(10),ta.order_change_datetime,112) = @rundate

select top 1 * into #header from #results where 1=0
insert #h (tradeid,sec_id,currency,exchg_rate)
	values ('H' + cast(@rundate as varchar(20)) + 'COMPANY',0,'','')
select top 1 * into #trailer from #results where 1=0
insert #trailer (tradeid,sec_id,currency,exchg_rate)
	values ('T','','','','')

;with f as
(
select * from #header
UNION
select * from #results
UNION
select * from #trailer
)
select * from f order by tradeid
