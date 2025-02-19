--Create this function, it will give exact date difference like year months days

    CREATE function get_Exact_Date_diff(@Date_Of_Birth smalldatetime,@Cur_Date smalldatetime)
 returns varchar(10)

    as

    begin

    declare @date3 smalldatetime

    Declare @month int,@year int,@day int

     if @Date_Of_Birth>@Cur_Date
     begin
     set @date3=@Cur_Date
     set @Cur_Date=@Date_Of_Birth
     set @Date_Of_Birth=@date3
     end



    SELECT @month=datediff (MONTH,@Date_Of_Birth,@Cur_Date)

    if dateadd(month,@month,@Date_Of_Birth) >@Cur_Date
    begin
    set @month=@month-1
    end
    set @day=DATEDIFF(day,dateadd(month,@month,@Date_Of_Birth),@Cur_Date)

    set @year=@month/12
    set @month=@month % 12

    return (case when @year=0 then '' when @year=1 then convert(varchar(5),@year ) + ' . ' when @year>1 then convert(varchar(5),@year ) + ' . ' end)
    + (case when @month=0 then '' when @month=1 then convert(varchar(5),@month ) + ' . ' when @month>1 then convert(varchar(5),@month ) + ' . ' end)
    + (case when @day=0 then '' when @day=1 then convert(varchar(5),@day ) + ' . ' when @day>1 then convert(varchar(5),@day ) + ' . ' end)

    end