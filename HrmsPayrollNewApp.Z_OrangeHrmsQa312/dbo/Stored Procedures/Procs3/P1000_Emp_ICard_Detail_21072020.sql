

Create PROCEDURE [dbo].[P1000_Emp_ICard_Detail_21072020]
	@CMP_ID				NUMERIC,
	@EFFECTIVE_DATE		DATETIME,
	--@BRANCH_ID			NUMERIC = 0,
	--@GRD_ID				NUMERIC = 0,
	--@VERTICAL_ID		NUMERIC = 0,
	--@SUBVERTICAL		NUMERIC = 0,
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
	@P_Branch		varchar(max) = '',
	@P_Vertical		varchar(max) = '',	
	@P_Subvertical		varchar(max) = '',
	@P_Department		varchar(max) = ''	
AS
BEGIN
         
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

    
	DECLARE @FROM_DATE DATETIME
	DECLARE @TO_DATE DATETIME
	DECLARE @MONTH_END_DATE DATETIME
	DECLARE @TEMP_CONSTRAINT VARCHAR(MAX);
	DECLARE @OUTOF_DAYS			NUMERIC        
	
	SET @FROM_DATE = dbo.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
	SET @TO_DATE = @EFFECTIVE_DATE
	SET @MONTH_END_DATE = dbo.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
	
	SET @OUTOF_DAYS = DATEDIFF(D,@FROM_DATE,@MONTH_END_DATE) + 1  

	--	THIS LOGIC IS IMPORTANT , THIS WILL BE USED , IF DATA IS TAKING TOO MUCH TO LOAD , ON CLIENT SIDE , THEN WE WILL SAVE THE DATA WHEN LOADED FIRST TIME , THEN IT WILL NOT BE LOADED FOR THAT DATA

	--SELECT	@TEMP_CONSTRAINT = COALESCE(@TEMP_CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	--FROM	dbo.Split(@CONSTRAINT,'#') T1 LEFT OUTER JOIN T0100_ADVANCE_PRESENT_DAYS T ON T.Emp_ID=Cast(T1.Data As numeric)
	--Where	T1.Data <> '' AND T.Emp_Id Is NUll
	
	
	
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
		select   @P_Branch = COALESCE(@P_Branch + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 
		set @P_Branch = @P_Branch + '#0'
	End
	
	if @P_Vertical is null
	Begin	
		select   @P_Vertical = COALESCE(@P_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID 
		
		If @P_Vertical IS NULL
			set @P_Vertical = '0';
		else
			set @P_Vertical = @P_Vertical + '#0'		
	End
	if @P_Subvertical is null
	Begin	
		select   @P_Subvertical = COALESCE(@P_Subvertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID 
		
		If @P_Subvertical IS NULL
			set @P_Subvertical = '0';
		else
			set @P_Subvertical = @P_Subvertical + '#0'
	End
	IF @P_Department is null
		Begin
				select @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
				
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

	--EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,0,@GRD_ID,0,0,0,@EMP_ID,@TEMP_CONSTRAINT ,0 ,0 ,0,@VERTICAL_ID,@SUBVERTICAL,0,0,0,0,0,0,0
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
	
	
	
	SELECT	E.EMP_ID,E.Alpha_Emp_Code, E.Emp_Full_Name,
			ISNULL(A.Is_Recovered,0) as Is_Recovered,A.Reason,
			CONVERT(varchar(11),A.Effective_Date,103) as Effective_Date
			,INC.Branch_ID,INC.Dept_ID,INC.Desig_Id,INC.Vertical_ID,INC.SubVertical_ID,INC.subBranch_ID,INC.Cat_ID,INC.Type_ID
			,A.Tran_ID,INC.Grd_ID,
			(case when A.Effective_Date IS NULL then CONVERT(varchar(11),E.Date_Of_Join,103) else CONVERT(varchar(11),@EFFECTIVE_DATE,103)  end )as Issue_date
	FROM	#EMP_CONS EC 
			INNER JOIN T0080_EMP_MASTER E ON EC.EMP_ID=E.Emp_ID		
			--LEFT OUTER JOIN (SELECT tran_Id,EMP_ID, Is_Recovered,Reason,Effective_Date 
			--				 FROM	V0100_Employee_Icard_Detail 
			--				 WHERE	Effective_Date <= @EFFECTIVE_DATE
			--				) A ON Ec.Emp_Id = A.Emp_ID
			LEFT OUTER JOIN
							(
								SELECT	Max(tran_Id)as Tran_Id ,Emp_ID
								FROM	V0100_Employee_Icard_Detail 
								WHERE	Effective_Date <= @EFFECTIVE_DATE
								GROUP by Emp_ID
							)Q On Q.Emp_ID = Ec.EMP_ID	Left OUTER JOIN
							V0100_Employee_Icard_Detail A On A.Tran_ID = Q.Tran_Id				
			INNER JOIN T0095_INCREMENT INC ON INC.Increment_ID = EC.Increment_ID	
		
	
	DROP TABLE #EMP_CONS
		
		
	
END


