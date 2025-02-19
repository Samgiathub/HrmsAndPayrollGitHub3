

--SP Created by Sumit for getting CTC Amount Year wise---------------------------------------------------------------
--on 30112016---------------------------------------------------
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_SALARY_GET_CTC]  
	@Company_id		Numeric  
	,@From_Date		Datetime
	,@To_Date 		Datetime
	,@Branch_ID		varchar(max)	
	,@Grade_ID 		varchar(max)
	,@Type_ID 		varchar(max)
	,@Dept_ID 		varchar(max)
	,@Desig_ID 		varchar(max)
	,@Emp_ID 		Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID        varchar(max)
	,@Order_By		varchar(100)=''
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
     If @Cat_ID = 0
        set @Cat_ID = null
        
     If @Type_id = 0
        set @Type_id = null
          	 
	 CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0
	 
	 
	 
		 CREATE TABLE #EMP_CTC_YEAR
		 (
			EMP_ID NUMERIC(18,0),
			CMP_ID NUMERIC(18,0),
			MONTH_NAME VARCHAR(25),
			CTC_AMOUNT NUMERIC(18,2),
			StartDate datetime,
			Branch_Id numeric(18,0)   ---Added by Jaina 11-01-2017
		 )	 	
			DECLARE @SQLQUERY_3 AS VARCHAR(max);		
		
			CREATE TABLE #DATES 
			(
				MonthStartDate DATETIME
			)
			;with cte as (
			  select convert(date,left(convert(varchar,@From_Date,112),6) + '01') startDate,
					 month(@From_Date) n
			  union all
			  select dateadd(month,n,convert(date,convert(varchar,year(@From_Date)) + '0101')) startDate,
					(n+1) n
			  from cte
			  where n < month(@From_Date) + datediff(month,@From_Date,@To_Date)
			)

			
			INSERT INTO #DATES
			SELECT startDate from cte option (maxrecursion 0);			
			
			insert into #EMP_CTC_YEAR			
					select		E.Emp_ID,@Company_id, 
								 LEFT(dbo.F_GET_MONTH_NAME(MONTH(MonthStartDate)), 3) + '--' + cast(YEAR(MonthStartDate) as varchar(25)) as Months ,								 
								0,
								D.MonthStartDate,E.Branch_ID
					from		#DATES D
								cross join #Emp_Cons E								
					order by	D.MonthStartDate asc

			
			update C set C.CTC_Amount=I.CTC
					from #EMP_CTC_YEAR C
					LEFT OUTER JOIN T0095_INCREMENT I on Month(I.Increment_Date) = Month(C.StartDate) 
					AND Year(I.Increment_Date) = Year(C.StartDate) and C.EMP_ID=I.Emp_ID

						
			Delete	from #EMP_CTC_YEAR
			where	CTC_AMOUNT is null or CTC_AMOUNT=0 			
			
			DECLARE @DynamicQuery AS NVARCHAR(MAX)
			DECLARE @ColumnName AS NVARCHAR(MAX)
			
			IF OBJECT_ID('tempdb..##TMPDATACTC') IS NOT NULL 
				Begin
					DROP TABLE ##TMPDATACTC
				End
						
			SET @ColumnName = NULL;
			DECLARE @Display_Cols Varchar(max);
			
			SELECT	@ColumnName = COALESCE(@ColumnName + ',','') + '[' + CONVERT(VARCHAR(10), STARTDATE,103) + ']',
					@Display_Cols = COALESCE(@Display_Cols + ',','') + '[' + CONVERT(VARCHAR(10), STARTDATE,103) + '] AS [' + MONTH_NAME + ']'
			FROM	(SELECT Distinct STARTDATE,MONTH_NAME FROM #EMP_CTC_YEAR) T
			ORDER BY STARTDATE			
			
			--select @ColumnName
        	
        	SET @DynamicQuery = N'SELECT Emp_ID,Branch_ID, ' + @Display_Cols + ' into  ##TMPDATACTC
				FROM (
						SELECT C.EMP_ID, C.CTC_AMOUNT,CONVERT(VARCHAR(10),C.STARTDATE,103)as STARTDATE,C.Branch_Id					
						FROM #EMP_CTC_YEAR C
					 ) AS PVT
				PIVOT(
						SUM(CTC_AMOUNT) 
						FOR STARTDATE IN (' + @ColumnName + ') 						
				)  AS PvtCTC '							
						
			exec (@DynamicQuery);
			
			IF OBJECT_ID('tempdb..##TMPDATACTC') IS Not NULL
			BEGIN
				
					select		'="' + Alpha_Emp_Code + '"' as Employee_Code,EM.Emp_Full_Name as Employee_Name,
								Case when EM.Gender = 'M' then 'Male' Else 'Female' End as Gender,BM.Branch_Name as Branch,DM.Dept_Name as Department,DSM.Desig_Name as Designation,
								GM.Grd_Name as Grade ,TM.Type_Name as Employee_Type,CM.Cat_Name as Category,
								VS.Vertical_Name As Vertical,SV.SubVertical_Name as Sub_Vertical,
								--I.Branch_ID,
								TC.* from ##TMPDATACTC TC 
								inner join #Emp_Cons EC on TC.Emp_ID =EC.EMp_ID					
								inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=EC.Emp_ID
								inner join T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID=EC.Increment_ID
								left join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=I.Branch_ID
								left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id=I.Dept_ID
								left join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=I.Desig_Id
								left join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID=I.Grd_ID
								left join T0040_TYPE_MASTER TM WITH (NOLOCK) on Tm.Type_ID=I.Type_ID
								left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on CM.Cat_ID=I.Cat_ID
								left join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I.Vertical_ID
								left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=I.SubVertical_ID					
	
			End
	drop table #EMP_CTC_YEAR
	drop table #DATES
	
Return




