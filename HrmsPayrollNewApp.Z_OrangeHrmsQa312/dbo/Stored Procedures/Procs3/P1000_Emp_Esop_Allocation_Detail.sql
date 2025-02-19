
CREATE PROCEDURE [dbo].[P1000_Emp_Esop_Allocation_Detail]
	@CMP_ID				NUMERIC,
	@EFFECTIVE_DATE		DATETIME,
	@BRANCH_ID			varchar(Max),
	@GRD_ID				varchar(Max),
	@Dept_Id			varchar(Max),
	@Desig_Id			varchar(Max),
	@Type_Id			varchar(Max),
	@Segment_Id			varchar(Max),
	@Cat_Id				varchar(Max),
	@VERTICAL_ID		varchar(Max),
	@SUBVERTICAL		varchar(Max),	
	@EMP_ID				NUMERIC = 0,
	@CONSTRAINT			VARCHAR(MAX) = '',
	@P_Branch			varchar(max) = '',
	@P_Vertical			varchar(max) = '',	
	@P_Subvertical		varchar(max) = '',
	@P_Department		varchar(max) = '',
	@Expiry_Day			varchar(5),
	@Filter_Date		int,
	@FilterFromDate		varchar(20),
	@FilterToDate		varchar(20)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
         
    
	DECLARE @FROM_DATE DATETIME
	DECLARE @TO_DATE DATETIME
	DECLARE @MONTH_END_DATE DATETIME
	DECLARE @TEMP_CONSTRAINT VARCHAR(MAX);
	DECLARE @OUTOF_DAYS			NUMERIC        
	
	SET @FROM_DATE = dbo.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
	SET @TO_DATE = @EFFECTIVE_DATE
	SET @MONTH_END_DATE = dbo.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
	
	SET @OUTOF_DAYS = DATEDIFF(D,@FROM_DATE,@MONTH_END_DATE) + 1  

	IF (@P_Branch = '' OR @P_Branch = '0') 
	SET @P_Branch = NULL;    
	
	 IF (@P_Vertical = '' OR @P_Vertical = '0') 
		SET @P_Vertical = NULL
		
	 IF (@P_Subvertical = '' OR @P_Subvertical = '0') 
		set @P_Subvertical = NULL
		
	IF (@P_Department = '' OR @P_Department = '0') 
		set @P_Department = NULL

	if @P_Branch is null
	Begin	
		select   @P_Branch = COALESCE(@P_Branch + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @P_Branch = @P_Branch + '#0'
	End
	
	if @P_Vertical is null
	Begin	
		select   @P_Vertical = COALESCE(@P_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @P_Vertical IS NULL
			set @P_Vertical = '0';
		else
			set @P_Vertical = @P_Vertical + '#0'		
	End
	if @P_Subvertical is null
	Begin	
		select   @P_Subvertical = COALESCE(@P_Subvertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @P_Subvertical IS NULL
			set @P_Subvertical = '0';
		else
			set @P_Subvertical = @P_Subvertical + '#0'
	End
	IF @P_Department is null
		Begin
				select @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
				
				if @P_Department is null
					set @P_Department = '0';
				else
					set @P_Department = @P_Department + '#0'
		End
	
	
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	)  

	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,
											@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   
	
	CREATE NONCLUSTERED INDEX IX_EMPCONS ON #EMP_CONS (EMP_ID)

	
	 IF (@P_Branch IS NOT NULL) 
		  BEGIN	  
			  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID			  
			  WHERE NOT EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
		  END
		  
		  IF (@P_Vertical IS NOT NULL) 
		  BEGIN	  
			  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
			  WHERE NOT EXISTS (select Data from dbo.Split(@P_Vertical, '#') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
			  
		  END
		  
		  IF (@P_Subvertical IS NOT NULL) 
		  BEGIN
			  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
			  WHERE NOT EXISTS (select Data from dbo.Split(@P_Subvertical, '#') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
		  END
		  
		  IF (@P_Department IS NOT NULL) 
		  BEGIN

			  DELETE #Emp_Cons FROM #Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.Increment_ID=I.Increment_ID AND I.Cmp_ID=@CMP_ID
			  WHERE NOT EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
		  END
	

	--IF @Required_Execution = 1
	--	BEGIN
	--		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
	--	END
	DECLARE @WHERE AS VARCHAR(500) 

	IF @FILTER_DATE = 1
	BEGIN
		set @where = 'WHERE CAST(E.DATE_OF_JOIN AS DATE) BETWEEN ''' + CONVERT(varchar(11),@FilterFromDate,20) + ''' and ''' + CONVERT(varchar(11),@FilterToDate,20) + ''''
	END
	ELSE IF @FILTER_DATE = 2
	BEGIN
		set @where = 'WHERE CAST(A.[EXPIRY_DATE] AS DATE) BETWEEN ''' + CONVERT(varchar(11),@FilterFromDate,20) + ''' and ''' + CONVERT(varchar(11),@FilterToDate,20) + ''''
	END
	Else
	Begin
		set @where = ''
	End

	DECLARE @QUERY AS VARCHAR(MAX)

	SET @QUERY = 'SELECT  
				NULL as Tran_Id
				,E.EMP_ID,E.Alpha_Emp_Code, E.Emp_Full_Name
				, NULL as EmployeeShare
			--,ISNULL(A.Is_Recovered,0) as Is_Recovered
			--,A.Reason
			--,CONVERT(varchar(11),A.Effective_Date,103) as Effective_Date
			--,INC.Branch_ID,INC.Dept_ID,INC.Desig_Id,INC.Vertical_ID,INC.SubVertical_ID,INC.subBranch_ID,INC.Cat_ID,INC.Type_ID ,A.Tran_ID,INC.Grd_ID,
			--(case when E.Date_Of_Join > ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' then E.Date_Of_Join
			--when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' end) as Issue_date
			--,case when e.Emp_Left_Date < DateAdd(DAY,' +  @Expiry_Day + '
			--,(case when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' end))
			--Then convert(varchar(11),e.Emp_Left_Date,103) 
			--ELSE (case when ' +  @Expiry_Day + ' <> 0 then Convert(varchar(50),DateAdd(DAY,' +  @Expiry_Day + ',(case when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ '''  end)),103)
			--else '''' end ) 
			--END Expired_date
			
			FROM	#EMP_CONS EC 
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.Emp_ID
			--LEFT OUTER JOIN( 
			--	SELECT	Max(tran_Id)as Tran_Id ,Emp_ID FROM	V0100_Employee_Icard_Detail   
			--	GROUP by Emp_ID 
			--)Q On Q.Emp_ID = Ec.EMP_ID	
			--Left OUTER JOIN V0100_Employee_Icard_Detail A On A.Tran_ID = Q.Tran_Id				
			INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON INC.Increment_ID = EC.Increment_ID  ' + @where + ''

	exec(@query)

	--SET @QUERY = 'SELECT  E.EMP_ID,E.Alpha_Emp_Code, E.Emp_Full_Name
	--		,ISNULL(A.Is_Recovered,0) as Is_Recovered
	--		,A.Reason
	--		,CONVERT(varchar(11),A.Effective_Date,103) as Effective_Date
	--		,INC.Branch_ID,INC.Dept_ID,INC.Desig_Id,INC.Vertical_ID,INC.SubVertical_ID,INC.subBranch_ID,INC.Cat_ID,INC.Type_ID ,A.Tran_ID,INC.Grd_ID,
	--		(case when E.Date_Of_Join > ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' then E.Date_Of_Join
	--		when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' end) as Issue_date
	--		,case when e.Emp_Left_Date < DateAdd(DAY,' +  @Expiry_Day + '
	--		,(case when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ ''' end))
	--		Then convert(varchar(11),e.Emp_Left_Date,103) 
	--		ELSE (case when ' +  @Expiry_Day + ' <> 0 then Convert(varchar(50),DateAdd(DAY,' +  @Expiry_Day + ',(case when A.Effective_Date IS NULL then E.Date_Of_Join else ''' +CONVERT(varchar(11),@EFFECTIVE_DATE,20)+ '''  end)),103)
	--		else '''' end ) 
	--		END Expired_date
	--		FROM	#EMP_CONS EC INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.Emp_ID
	--		LEFT OUTER JOIN( SELECT	Max(tran_Id)as Tran_Id ,Emp_ID FROM	V0100_Employee_Icard_Detail   GROUP by Emp_ID )Q On Q.Emp_ID = Ec.EMP_ID	Left OUTER JOIN V0100_Employee_Icard_Detail A On A.Tran_ID = Q.Tran_Id				
	--		INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON INC.Increment_ID = EC.Increment_ID  ' + @where + ''

	--exec(@query)
	DROP TABLE #EMP_CONS
END



