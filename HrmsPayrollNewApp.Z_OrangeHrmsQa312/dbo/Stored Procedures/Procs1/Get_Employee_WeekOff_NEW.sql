

-- =============================================
-- Author:		<Jaina>
-- Create date: <13-09-2016>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Employee_WeekOff_NEW]
	@Cmp_Id as numeric(18,2)
	,@Emp_id as numeric(18,2)
	,@Month as numeric
	,@Year as numeric
	,@IsUpdate as numeric  = 0
	,@WO_Application_Id as numeric = 0  --Added By Jaina 13-09-2016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		CREATE TABLE #tblWoHo
        (
           Emp_id NUMERIC(18) ,
           Cmp_id NUMERIC(18) ,
           Branch_id NUMERIC(18) ,
           WO_date NVARCHAR(MAX) ,
           HO_date NVARCHAR(MAX) ,
           WO_Count NUMERIC(18, 0) ,
           HO_Count NUMERIC(18, 0) ,
           mid_WO_date NVARCHAR(MAX) ,
           mid_WO_Count NUMERIC(18, 0)
         )
            
        Declare @from_date as datetime
        Declare @to_date as datetime
        Set @from_date = DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0)) /*First*/
		Set @to_date = DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0))) /*Last*/
		
		create table #Emp_Weekoff
		(
			Emp_ID Numeric(18,0)  
			,Cmp_ID  Numeric(18,0)  
			,For_Date Datetime
			,W_Day  Numeric(18,0)  
		)
		
		Declare @Weekoff_Days   Numeric(12,1)    
		Declare @Cancel_Weekoff   Numeric(12,1)  
		Declare  @StrWeekoff_Date varchar(Max)
		Declare  @varCancelWeekOff_Date 	varchar(max) 
		
		set @StrWeekoff_Date=''
		set @Weekoff_Days=0
		set @Cancel_Weekoff=0
		set @varCancelWeekOff_Date = ''
    
		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_id,@Cmp_Id,@from_date,@to_date,null,null,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,1,0,0,@varCancelWeekOff_Date		

		CREATE TABLE #tblWeekOff
        (
		   Cmp_Id numeric,
           Emp_Id numeric,
           WODate datetime,
           WODate1 varchar(30),
           [Day] varchar(50),
           NoOfDate nvarchar(5),
           NewWODate datetime,
           NewDay varchar(50),
           Status varchar(1),
           Is_Active tinyint default 1,
           WO_Application_Id numeric default 0
           
        )
        
        Insert into #tblWeekOff 
			Select EW.Cmp_ID,EW.Emp_ID,For_Date
			,RIGHT('0' + DATENAME(DAY, For_Date), 2) + '-' + DATENAME(MONTH, For_Date)+ '-' + DATENAME(YEAR, For_Date)
			,datename(dw,For_Date),'0',null,null,'',case when isnull(ms.Sal_tran_id ,0) =0 then 1 else 0 end  -- Added by rohit on 29082016
			, 0
			from #Emp_Weekoff EW left join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on Ew.Emp_ID =Ms.Emp_ID and EW.For_Date >= MS.Month_St_Date and Ew.For_Date <= MS.Month_End_Date
			
				
		IF EXISTS (select WO_Application_Id from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year)
			BEGIN
					Update #tblWeekOff Set
					Status = (
									CASE WHEN EXISTS(Select Status from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										THEN
											(Select Status from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										ELSE
											(Select #tblWeekOff.Status)
										END	
							 )			
					,WO_Application_Id = (
									CASE WHEN EXISTS(Select WO_Application_Id from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										THEN
											(Select WO_Application_Id from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										ELSE
											(Select #tblWeekOff.WO_Application_Id)
										END	
							 )			
							 
							 
					Update #tblWeekOff
					Set NoOfDate = 0,
					NewWODate = (
									CASE WHEN EXISTS(Select New_WO_Date from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										THEN
											(Select New_WO_Date from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = #tblWeekOff.WODate)
										ELSE
											(Select #tblWeekOff.WODate)
										END							
								)
								
					Update #tblWeekOff Set
					Status = (
									CASE WHEN EXISTS(Select Status from T0120_WO_Approval WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and New_WO_Date = #tblWeekOff.NewWODate)
										THEN
											(Select Status from T0120_WO_Approval WITH (NOLOCK) where Emp_Id = @Emp_id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and New_WO_Date = #tblWeekOff.NewWODate)
										ELSE
											(Select #tblWeekOff.Status)
										END	
							 )								
							
																				
					Update #tblWeekOff
					 Set NewDay = (datename(dw,NewWODate))
			END
		ELSE
			BEGIN
					Update #tblWeekOff
					Set NewWODate = DATEADD(DAY,CAST(NoOfDate as numeric),WODate)
					,NewDay = datename(dw,DATEADD(DAY,CAST(NoOfDate as numeric),WODate))
			END
		


		if @IsUpdate = 0
			Begin 
				
				SELECT Cmp_Id,Emp_Id,CONVERT(varchar(30),WODate,103) as WODate
						,WODate1,DAY,NoOfDate
						,CONVERT(varchar(30),NewWODate,103) as NewWODate,NewDay 
						,Status
						,ISNULL(Status,'P') as Application_Status
						,Is_Active,WO_Application_Id
						FROM #tblWeekOff --WHERE Status = '' 		
						order by WODate		
					
			End
		ELSE
			BEGIN
				
					IF EXISTS (Select ISNULL(Status,'P') from #tblWeekOff where Status = 'A'and WO_Application_Id = @WO_Application_Id)
						BEGIN	
						
							SELECT Cmp_Id,Emp_Id,CONVERT(varchar(30),WODate,103) as WODate
							,WODate1,DAY,NoOfDate
							,CONVERT(varchar(30),NewWODate,103) as NewWODate,NewDay 
							,CASE WHEN ISNULL(Status,'P') = 'P' THEN '<span style="color: Red;">Pending</span>' ELSE '<span style="color: Green;">Approved</span>' END Status
							,ISNULL(Status,'P') as Application_Status
							,Is_Active,WO_Application_Id
							FROM #tblWeekOff WHERE Status = 'A'	and WO_Application_Id = @WO_Application_Id
							order by WODate
							
						END
					ELSE
						BEGIN
						
							SELECT Cmp_Id,Emp_Id,CONVERT(varchar(30),WODate,103) as WODate
							,WODate1,DAY,NoOfDate
							,CONVERT(varchar(30),NewWODate,103) as NewWODate,NewDay 
							,CASE WHEN ISNULL(Status,'P') = 'P' THEN '<span style="color: Red;">Pending</span>' ELSE '<span style="color: Green;">Approved</span>' END Status
							,ISNULL(Status,'P') as Application_Status
							,Is_Active,WO_Application_Id
							FROM #tblWeekOff WHERE Status = 'P' and WO_Application_Id = @WO_Application_Id 		
							order by WODate
					END		
			END
END

