
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GROUP_WISE_INCREMENT_DETAILS]  
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
	,@Group_Wise	Numeric = 1 
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
	 
	DECLARE @GroupBY Varchar(100)
    DECLARE @GroupName Varchar(100)
    
    DECLARE @W_JOIN Varchar(Max)
	SET @W_JOIN = ''

	IF @Group_Wise = 1
	   Begin
			SET @GroupBY = 'Desig_Id'
			SET @GroupName = 'Desig_Name as Designation'
			SET @W_JOIN = 'INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = ED.Desig_Id'
	   End
	Else IF @Group_Wise = 2
	   Begin
		   SET @GroupBY = 'Dept_ID'
		   SET @GroupName = 'Dept_Name as Department'
		   SET @W_JOIN = 'INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_ID = ED.Dept_ID'
	   END
	Else IF @Group_Wise = 3
	   Begin
		   SET @GroupBY = 'Grd_ID'
		   SET @GroupName = 'Grd_Name as Grade'
		   SET @W_JOIN = 'INNER JOIN T0040_GRADE_MASTER DM WITH (NOLOCK) ON DM.Grd_ID = ED.Grd_ID'
	   END
	   
	Else IF @Group_Wise = 4
	   Begin
		   SET @GroupBY = 'Branch_ID'
		   SET @GroupName = 'Branch_Name as Branch'
		   SET @W_JOIN = 'INNER JOIN T0030_BRANCH_MASTER DM WITH (NOLOCK) ON DM.Branch_ID = ED.Branch_ID'
	   END

	IF object_ID('tempdb..#EmpData') is not null
		Drop TABLE #EmpData
	
	Create Table #EmpData
	(
		Row_ID Numeric,
		Cmp_ID Numeric,
		Emp_ID Numeric,
		Eff_Date Datetime,
		Gross_Salary Numeric(18,2)
	)

	DECLARE @W_SQL Varchar(Max)
	SET @W_SQL = ''

	SET @W_SQL = 'ALTER TABLE #EmpData ADD ' + @GroupBY + ' Varchar(20)'
	EXEC(@W_SQL)

	SET @W_SQL = ''
	SET @W_SQL = 'Insert INTO #EmpData
				SELECT ROW_NUMBER() Over(ORDER BY Increment_Effective_Date) as Row_ID,Cmp_ID, I.Emp_ID,Increment_Effective_Date,Gross_Salary,I.' + @GroupBY + '
				FROM T0095_INCREMENT I WITH (NOLOCK) Inner Join #Emp_Cons EC ON I.Emp_ID = EC.Emp_ID
				Group BY I.Emp_ID,I.Cmp_ID,I.' + @GroupBY + ',Increment_Effective_Date,Gross_Salary
				order BY I.Emp_ID,I.Cmp_ID'
				-- Where Increment_Type not In (''Transfer'',''Deputation'')
	EXEC(@W_SQL)
 
	-- Added Condition by Hardik on 14/02/2020 for Unison as Dates showing wrong if 2 times same designation assign on different increment effective dates
	SET @W_SQL = ''
	SET @W_SQL = 'Update ED Set Row_Id = Case When E.'+ @GroupBY +' = ED.'+ @GroupBY +' Then 1 Else 0 End from #EmpData ED
					Left Outer Join #EmpData E on E.Row_Id = ED.Row_Id-1'
	EXEC(@W_SQL)



    SET @W_SQL = ''
		SET @W_SQL = 'Select EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.' + @GroupName + ',ED.Eff_Date as Effective_Date,ED.Gross_Salary
		FROM #EmpData ED
		Inner JOIN(
					Select MIN(Row_ID) as RowID,Emp_ID,' + @GroupBY + ' 
						From #EmpData
					Group BY Emp_ID,' + @GroupBY + '
				  ) as Qry 
		ON ED.Row_ID = Qry.RowID AND ED.Emp_ID = Qry.Emp_ID AND ED.' + @GroupBY + ' = Qry.' + @GroupBY + '
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = ED.Emp_ID
		' + @W_JOIN + '
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = ED.Cmp_ID
		ORDER BY EM.Alpha_Emp_Code,ED.Eff_Date,ED.Emp_ID,ED.Cmp_ID'
	--PRINT @W_SQL
	EXEC(@W_SQL)
    
  


