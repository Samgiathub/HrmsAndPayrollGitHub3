


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 11-Jun-2019
-- Description:	To Calculate the Work Experience. This logic is bit different than Age Calculation.
-- =============================================
CREATE FUNCTION [dbo].[F_GET_EXP] 
(
	@Date_Of_Birth as datetime =null,
	@Cur_Date as datetime,
	@With_month as varchar(1) ='Y',
	@With_Days as varchar(1) = 'Y'		
)
RETURNS Varchar(10)
AS
	BEGIN
	--Mansi start for Year Month difference 17-6-21
			Declare @Age varchar(10)
			declare @total_Days as int
			Declare @year as int
			declare @month as int
			declare @days as int
					set @year=(DATEDIFF(YEAR, @Date_Of_Birth, @Cur_Date))
					set @month=  (DATEDIFF(MONTH, @Date_Of_Birth, @Cur_Date))
					set @days= (DATEDIFF(day, @Date_Of_Birth, @Cur_Date))   ---Gives days between dates
			        declare @TotalDays varchar(10)
					set @TotalDays=cast(@days as varchar(5))+1    --added 1 days for Considering Enddate in calculation 
                    Declare @Aday varchar(10)                    
					--set @Aday=cast(@TotalDays as numeric(18,0))%365.25
					declare @Ayr varchar(5),@m varchar(5)
			    	set @m=dbo.fn_ConvertDaysToMonths(@TotalDays)    --- @m gives Total month 
				--set @yr=Round((@m/12),0)
				    set @Ayr=floor(@m/12)                --shows year from month
				declare @Am varchar(5)
				set @Am=(@m%12)                          -- gives Remaining month 
				--set @Age =cast(@yr as varchar(5))+'.'+cast(@Am as varchar(5))
		  return cast(@Ayr as varchar(5))+'.'+cast(@Am as varchar(5))
		  --Mansi end  for Year Month difference 17-6-21

	 --    --commented  Code start as it not gives exact year,month   mansi 17-6-21   
		--Declare @Age varchar(10)
		--declare @total_Days as int
			
		--Declare @year as int
		--declare @month as int
		--declare @days as int

		--DECLARE @thisYearBirthDay datetime
			
		--set @thisYearBirthDay = DATEADD(year, DATEDIFF(year, @Date_Of_Birth, @Cur_Date), @Date_Of_Birth)
		--set @year = DATEDIFF(year, @Date_Of_Birth, @Cur_Date) - (CASE WHEN @thisYearBirthDay > @Cur_Date THEN 1 ELSE 0 END)
		--set @month = MONTH(@Cur_Date - @thisYearBirthDay) 
		--set @days = DAY(@Cur_Date - @thisYearBirthDay) --by mansi

						
		--set @Age = cast(@year  as varchar(5))
		--if @With_Month ='Y' 
		--	set @Age = @Age +'.' + cast(@Month as varchar(5))
		--if @With_Days ='Y'
		--	set @Age = @Age +'.' + cast(@Days as varchar(5))
			
		--RETURN @Age 
		-- --commented  Code end as it not gives exact year,month   mansi 17-6-21   
	END

