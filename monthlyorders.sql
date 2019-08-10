/* 
* Stored procedure to get counts of orders for all active client for a given month
*/

use F_DATABASE
go

if exists
(
select 1 from sysobjects
where name = "monthlyorders"
)
begin
    print "monthlyorders: dropping existing procedure..."
    drop procedure monthlyorders
end
go

create procedure monthlyorders
(
    @activity_date char(6) = null
)
as

begin
    declare
        @search_date                 char(8),
        @search_month                char(7),
        @printdate                   varchar(32),
        @begindate                   varchar(32),
        @error_message               varchar(150),
        @return_error                int,
        @counter                     int,
        @order_count                 int,
        @cur_cpty_id                 DT_COUNTERPARTY_ID

    if @activity_date is null
    begin
       select @activity_date = convert(varchar,getdate(),112)
       select @search_date  = substring(convert(varchar,dateadd(month, -1, convert(datetime,@activity_date)),112),1,8)
       select @search_month = substring(@search_date,1,6) + "%"
    end
    else
    begin
        select @search_month = @activity_date + "%"
        print '*****MONTH       :      %1!',@search_month
    end

    select @counter = 0

    set nocount on

    -- STAGE 1: Open cursor/Default variables

    declare rSP_cursor cursor for
    select COUNTERPARTY_ID 
      from COUNTERPARTY 
     where COUNTERPARTY_TYPE in ('C') and STATUS='A'
    for read only

    open rSP_cursor

    fetch rSP_cursor into
         @cur_cpty_id

    /* Generic check of cursor */
    if @@sqlstatus = 1
    begin
        raiserror 50000 'ERROR: Failed reading COUNTERPARTY table'
        return 1
    end
    else 
    if @@sqlstatus = 2 
    begin
        print 'No data in COUNTERPARTY table'
    end
    
    /* Begin cursor loop */
    while @@sqlstatus = 0
    begin

    /* STAGE 2: Check the validity of the data and control parameters */

        select @counter = @counter + 1

        if @counter = 1
        begin
            select @begindate = getdate()
             print 'TIME: monthlyorders began at %1!',@begindate
             print '**'
        end

        /* print every 10 records */
        if @counter % 500 = 0
        begin
            select @printdate = getdate()
            print 'COUNT: %1! rows at %2!', @counter,@printdate
        end

        select @order_count = count(*)
          from TB_ORDER_AUDIT
         where COUNTERPARTY_ID = @cur_cpty_id
           and ENTERED_DATETIME like @search_month

        if @order_count > 0
        begin
 
            print 'COUNTERPARTY: %1!, COUNT: %2!',@cur_cpty_id, @order_count
            print ''

        end

        fetch rSP_cursor into
                @cur_cpty_id
   
        if @@sqlstatus = 1
        begin
            raiserror 50000 'ERROR: Failed reading COUNTERPARTY table'
            return 1
        end
    end

    close rSP_cursor

    deallocate cursor rSP_cursor

end
go

if @@error = 0
begin
    print 'monthlyorders: procedure created.'
end
go

grant execute on dbo.monthlyorders to FDA_GRP_REPORT
go
