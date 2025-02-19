

-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <03/12/2015>
-- Description:	<Get Week,Monthly,Quaterly Start date,end date>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_Duration_Dates]
	@Year_Start_Date datetime,
	@Year_End_Date	datetime,
	@STR_WEEKOFF	varchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Create table #Date_Validity_temp
	(
		St_date	 datetime,
		End_Date datetime,
		Duration varchar(10)
	)
			
				Declare @temp_Date as datetime
				declare @i as numeric
				declare @Weeks as numeric
				
				set @temp_Date = @Year_Start_Date
				set @i = 0
				set @Weeks = 0
				while @i < 12 -- Monthly Date
					begin
						set @temp_Date = DATEADD(m,@i,@Year_Start_Date)
						Insert into #Date_Validity_temp
							select dbo.GET_MONTH_ST_DATE(month(@temp_Date),Year(@temp_Date)) ,dbo.GET_MONTH_END_DATE(month(@temp_Date),Year(@temp_Date)),'Monthly'		 
						
						IF @i % 3 = 0 -- Quarterly Date
							begin
							
								Insert into #Date_Validity_temp
									select dbo.GET_MONTH_ST_DATE(month(@temp_Date),Year(@temp_Date)) ,dateadd(M,2,dbo.GET_MONTH_END_DATE(month(@temp_Date),Year(@temp_Date))),'Quarterly'		 
							end		
								
						set @i = @i + 1
					end 
				
			
				IF @STR_WEEKOFF	 <> ''
					BEGIN
						INSERT INTO #DATE_VALIDITY_TEMP			
							SELECT CASE WHEN @YEAR_START_DATE > DATEADD(DAY,-6,DATA) THEN 
								@YEAR_START_DATE 
							ELSE 
								DATEADD(DAY,-6,DATA) 
							END AS FROM_DATE ,
							DATA AS TO_DATE,'WEEKLY' FROM DBO.SPLIT(@STR_WEEKOFF,';') where Data <> ''
							
						INSERT INTO #DATE_VALIDITY_TEMP				
							SELECT TOP 1 DATEADD(DAY,1,DATA),@YEAR_END_DATE ,'WEEKLY' 
							FROM DBO.SPLIT(@STR_WEEKOFF,';') WHERE DATA <> '' and @Year_End_Date <> cast(Data AS datetime)  
							ORDER BY cast(DATA as datetime) DESC
							
					END
				-- set @i = 0
				-- set @Weeks = DATEDIFF(WEEK,@Year_Start_Date,@Year_End_Date)
					
				--while @i < @Weeks  -- Week Date
				--	begin
					
				--		set @temp_Date = DATEADD(WEEK,@i,@Year_Start_Date)
						
				--		Insert into #Date_Validity_temp			
				--		select  @temp_Date,Dateadd(day,6,@temp_Date),'Weekly'
					
				--		set @i = @i + 1
				--	end
					
	select * from #Date_Validity_temp order by Duration,St_Date
END


