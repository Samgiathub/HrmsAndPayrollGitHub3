
create FUNCTION [dbo].[F_GET_AGE_For_Employee_Master_Application] 
	(
		@Date_Of_Birth as datetime =null,
		@Cur_Date as datetime,
		@With_month as varchar(1) ='Y',
		@With_Days as varchar(1) = 'Y'
		
	)
RETURNS Varchar(10)
AS
		begin
		--declare @Age int
			Declare @Age varchar(10)
			declare @total_Days as int
			Declare @year as int
			declare @month as int
			declare @days as int

			--set @Total_Days = datediff(d,@Date_Of_Birth,@Cur_date)+1
		
			--if isnull(@Date_Of_Birth,'') <> ''
			--	begin
			--		if @Total_Days > 0
			--			begin
							
			--				set @Days = @total_Days % 365
			--				set @Year = (@Total_Days - @Days ) /365
			--				set @Total_Days = @Days 		
								
			--			end
			--		if @Total_Days > 0
			--			begin
			--				set @Days = @total_Days % 30
			--				set @Month = (@Total_Days - @Days ) /30
			--			end
			--		--added by Falak on 28-DEC-2010 coz when days is 0 then age is return NULL
			--		if @Month is null
			--			set @month = 0
			--		if @Days is null
			--			set @Days = 0
					
					
					--- Changed by Hardik on 18/03/2014 as above function was giving Days wrong, Check with this query  :-- select dbo.F_Get_Age('11-Oct-1982',getdate(),'Y','Y')
					--section original start
			--		DECLARE @thisYearBirthDay datetime
			
			--		set @thisYearBirthDay = DATEADD(year, DATEDIFF(year, @Date_Of_Birth, @Cur_Date), @Date_Of_Birth)
			--		set @year = DATEDIFF(year, @Date_Of_Birth, @Cur_Date) - (CASE WHEN @thisYearBirthDay > @Cur_Date THEN 1 ELSE 0 END)
			--		set @month = MONTH(@Cur_Date - @thisYearBirthDay) - 1
			--		set @days = DAY(@Cur_Date - @thisYearBirthDay) - 1			
					

			--		--if @month >= 12
			--		--begin
			--		--	declare @m numeric = 0
			--		--	set @m = @month - 12
			--		--	if @m = 0
			--		--	begin
			--		--		set @year = @year + 1
			--		--		set @month = 0
			--		--	end
			--		--	else if @m > 0
			--		--	begin
			--		--		set @month = @m	
			--		--	end
			--		--end

			--		set @Age = cast(@year  as varchar(5))
			--		if @With_Month ='Y' 
			--			set @Age = @Age +'.' + cast(@Month as varchar(5))
			--		if @With_Days ='Y'
			--			set @Age = @Age +'.' + cast(@Days as varchar(5))
			----end				
			
			--RETURN @Age
			--Mansi start for Year Month difference 17-6-21
					set @year=(DATEDIFF(YEAR, @Date_Of_Birth, @Cur_Date))
					set @month=  (DATEDIFF(MONTH, @Date_Of_Birth, @Cur_Date))
					set @days= (DATEDIFF(day, @Date_Of_Birth, @Cur_Date))
			        declare @TotalDays varchar(10)
					set @TotalDays=cast(@days as varchar(5))+1    --for Considering Enddate in calculation 
                    Declare @Aday varchar(10)                    
					--set @Aday=cast(@TotalDays as numeric(18,0))%365.25
					declare @Ayr varchar(5),@m varchar(5)
				set @m=dbo.fn_ConvertDaysToMonths(@TotalDays)
				--set @yr=Round((@m/12),0)
				set @Ayr=floor(@m/12)
				declare @Am varchar(5)
				set @Am=(@m%12)
				--set @Age =cast(@yr as varchar(5))+'.'+cast(@Am as varchar(5))
				declare @E_age varchar
				set @E_age=cast(@Ayr as varchar(5))+'.'+cast(@Am as varchar(5))

		  --return cast(@Ayr as varchar(5))+'.'+cast(@Am as varchar(5))
		    return cast(@Ayr as varchar(5))--+'.'+cast(@Am as varchar(5))
		  --Mansi end  for Year Month difference 17-6-21
		end






