


---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Make_Duration]
	 @For_date datetime	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
	
	declare @currmonthday as numeric(18,0)
	declare @monthday as numeric(18,0)
	declare @nextmonthday as numeric(18,0)
	declare @nextmonth as numeric(18,0)
	declare @nextyear as numeric(18,0)
	Declare @to_date as datetime
	declare @int as int
	set @int=0
	
	while (@int < 240)	
		Begin
		if not exists(select * from Salary_Period WITH (NOLOCK) where from_date >= @For_date and end_date <= @For_date)
			Begin
				set @currmonthday = DATEDIFF(d,@For_date,dbo.GET_MONTH_END_DATE(month(@for_date),year(@for_date)))+1
				set @monthday= dbo.GetNumDaysInMonth(dateadd(m,1,@For_date))
				
				set  @nextmonthday =@monthday-@currmonthday-1
				
				set @nextyear=year(dateadd(m,1,@For_date))
				set @nextmonth =MONTH(dateadd(m,1,@For_date))
				set @to_date= DATEADD(d,@nextmonthday,dbo.GET_MONTH_ST_DATE(@nextmonth ,@nextyear))
								
				insert into Salary_Period values (@nextmonth,@nextyear,@For_date,@to_date)
				set @For_date =DATEADD(d,1,@to_date)
				set @int =@int+1

			End 	
		end
		
RETURN














