

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CTC_HISTORY]  
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
	,@Report_Type	Numeric = 1 
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
	 
	
    if Object_ID('tempdb..#EMP_CTC_YEAR') is not null
		Begin
			Drop table #EMP_CTC_YEAR
		End
	
	CREATE TABLE #EMP_CTC_YEAR
	(
		EMP_ID NUMERIC(18,0),
		CMP_ID NUMERIC(18,0),
		MONTH_NAME VARCHAR(25),
		CTC_AMOUNT Varchar(Max),
		StartDate datetime,
		Branch_Id numeric(18,0)   ---Added by Jaina 11-01-2017
	)	
	
	If OBJECT_ID('tempdb..#EmpInc') is not null
		Begin
			Drop table #EmpInc
		End 
	
	Create Table #EmpInc
	(
		Emp_ID Numeric,
		CMP_ID Numeric,
		Increment_Effective_Date Datetime,
		CTC Numeric(18,2),
		Basic_Sal Numeric(18,2),
		Cal_CTC Numeric(18,2)
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
					LEFT(dbo.F_GET_MONTH_NAME(MONTH(MonthStartDate)), 3) + '-' + cast(YEAR(MonthStartDate) as varchar(25)) as Months ,								 
				0,
				D.MonthStartDate,E.Branch_ID
	from		#DATES D
				cross join #Emp_Cons E								
	order by	D.MonthStartDate asc

	Insert into #EmpInc
	select b.Emp_ID,Cmp_ID,Increment_Effective_Date,(Case When @Report_Type = 1 then CTC Else Gross_Salary End),Basic_Salary,0 
		from T0095_INCREMENT b WITH (NOLOCK)
		Inner Join #Emp_Cons EC ON b.Emp_ID = EC.Emp_ID
	WHERE b.Increment_Effective_Date >= @From_Date 
	and b.Increment_Effective_Date <= @To_Date and Increment_Type not In ('Transfer','Deputation')

	Declare @Inc_Cmp_ID Numeric
	Declare @Inc_Emp_ID Numeric
	Declare @Inc_Inc_Eff_Date Datetime
	Declare @Inc_Basic_Sal Numeric

	Set @Inc_Cmp_ID = 0
	Set @Inc_Emp_ID = 0
	Set @Inc_Inc_Eff_Date  = ''
	Set @Inc_Basic_Sal = 0

	Declare @Inc_CTC Numeric(18,2)
	Set @Inc_CTC = 0
	
	Declare Cur_Emp_Inc Cursor for
	Select Cmp_ID,Emp_ID,Increment_Effective_Date,Basic_Sal From #EmpInc
		Open Cur_Emp_Inc
	fetch next from Cur_Emp_Inc into @Inc_Cmp_ID,@Inc_Emp_ID,@Inc_Inc_Eff_Date,@Inc_Basic_Sal
		While @@FETCH_STATUS = 0
			Begin
					Select * Into #IncrementData From dbo.fn_getEmpIncrementDetail(@Inc_Cmp_ID,@Inc_Emp_ID,@Inc_Inc_Eff_Date)
					
					if @Report_Type = 1 
						Begin
							Select @Inc_CTC = @Inc_Basic_Sal +  SUM(EI.E_AD_AMOUNT) From #IncrementData EI Inner Join T0050_AD_Master AD WITH (NOLOCK) ON EI.AD_ID = AD.AD_ID 
							Where E_AD_FLAG = 'I' and AD.AD_PART_OF_CTC = 1
						End
					Else
						Begin
							Select @Inc_CTC = @Inc_Basic_Sal +  SUM(EI.E_AD_AMOUNT) From #IncrementData EI Inner Join T0050_AD_Master AD WITH (NOLOCK) ON EI.AD_ID = AD.AD_ID 
							Where E_AD_FLAG = 'I' and isnull(AD.AD_NOT_EFFECT_SALARY,0) = 0
						End

					Update #EmpInc 
							Set Cal_CTC = @Inc_CTC
					Where Emp_ID = @Inc_Emp_ID and CMP_ID = @Inc_Cmp_ID and Increment_Effective_Date = @Inc_Inc_Eff_Date

					Drop Table #IncrementData

				fetch next from Cur_Emp_Inc into @Inc_Cmp_ID,@Inc_Emp_ID,@Inc_Inc_Eff_Date,@Inc_Basic_Sal
			End
	close Cur_Emp_Inc
	deallocate Cur_Emp_Inc 


			update C 
				set C.CTC_Amount=Qry.CTC_Details
			from #EMP_CTC_YEAR C 
				Inner join(
							SELECT STUFF((
								select '/'+ cast(CAST(Cal_CTC as numeric) as varchar(255)) 
									from #EmpInc b
									WHERE a.Emp_ID= b.Emp_ID and Month(a.Increment_Effective_Date) = Month(b.Increment_Effective_Date) 
										and Year(a.Increment_Effective_Date) = Year(b.Increment_Effective_Date)
								FOR XML PATH('')),1,1,'') AS CTC_Details,
								a.Emp_ID,Month(Increment_Effective_Date) as Inc_Month,Year(Increment_Effective_Date) as Inc_Year
							FROM #EmpInc a
							GROUP BY a.Emp_ID,Month(Increment_Effective_Date),Year(Increment_Effective_Date)
						) as Qry 
				ON Month(C.StartDate) = Qry.Inc_Month and Year(C.StartDate) = Qry.Inc_Year and C.EMP_ID = Qry.Emp_ID
						
			Delete	from #EMP_CTC_YEAR
			where	CTC_AMOUNT is null or CTC_AMOUNT= '0' 	
			
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
			
			
        	SET @DynamicQuery = N'SELECT Emp_ID,Branch_ID, ' + @Display_Cols + ' into  ##TMPDATACTC
				FROM (
						SELECT C.EMP_ID, C.CTC_AMOUNT,CONVERT(VARCHAR(10),C.STARTDATE,103)as STARTDATE,C.Branch_Id					
						FROM #EMP_CTC_YEAR C
					 ) AS PVT
				PIVOT(
						max(CTC_AMOUNT) 
						FOR STARTDATE IN (' + @ColumnName + ') 						
				)  AS PvtCTC '							
			Print @DynamicQuery			
			exec (@DynamicQuery);
			
			IF OBJECT_ID('tempdb..##TMPDATACTC') IS Not NULL
			BEGIN
				
					select		'="' + Alpha_Emp_Code + '"' as Employee_Code,EM.Emp_Full_Name as Employee_Name,
								Case when EM.Gender = 'M' then 'Male' Else 'Female' End as Gender,
								BM.Branch_Name as Branch,DM.Dept_Name as Department,DSM.Desig_Name as Designation,
								GM.Grd_Name as Grade,
								dbo.Get_Age_CountDMY(EM.Date_Of_Join,GETDATE(),'YM') as Current_Exp,
								TC.* from ##TMPDATACTC TC 
								inner join #Emp_Cons EC on TC.Emp_ID =EC.EMp_ID					
								inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=EC.Emp_ID
								inner join T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID=EC.Increment_ID
								left join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=I.Branch_ID
								left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id=I.Dept_ID
								left join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=I.Desig_Id
								left join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID=I.Grd_ID				
	
			End

	drop table #EMP_CTC_YEAR
	drop table #DATES
	
Return




