CREATE PROCEDURE [dbo].[GetSurvey_EmpResponse]
	 @Survey_Id		numeric(18,0)
	,@Cmp_Id		numeric(18,0)
	,@Emp_Id		numeric(18,0)
	,@emp_code		varchar(200)=''
	,@Branch_Id		VARCHAR(MAX) = ''
	,@Desig_Id		VARCHAR(MAX) = ''
	,@Dept_Id		VARCHAR(MAX) = ''
AS
BEGIN

	IF @Branch_Id='0' OR @Branch_Id=''
		SET @Branch_Id=NULL
	IF @Desig_Id='0' OR @Desig_Id=''
		SET @Desig_Id=NULL
	IF @Dept_Id='0' OR @Dept_Id=''
		SET @Dept_Id=NULL
	IF @emp_code=''
		SET @emp_code=NULL
	create table #tempTable
	(
		 Survey_Id				numeric(18,0)	
		,Survey_Question		nvarchar(500)
		,Survey_Type			varchar(50)	
		,Sorting_No				int	
		,SurveyQuestion_Id		numeric(18,0)
		,SurveyEmp_Id			numeric(18,0)
		,Emp_Id					numeric(18,0)
		,Answer					nvarchar(max)
		,Response_Date			datetime
		,SubQuestion			int	
		,Is_Mandatory			int
	)
	
	declare @col1 numeric(18,0)
	
	--SELECT EM.Emp_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name)Emp_Full_Name,Answer,EM.Alpha_Emp_Code,Response_Date,SurveyEmp_Id,I.Branch_ID,I.Dept_ID
	----INTO #FINAL_EMP
	--FROM T0080_EMP_MASTER EM
	--INNER JOIN T0060_SurveyEmployee_Response SR ON SR.Emp_Id=EM.Emp_ID 
	--INNER JOIN V0080_EMP_MASTER_INCREMENT_GET I ON I.Emp_ID = EM.Emp_ID 
	--WHERE  Survey_Id = @Survey_Id AND (EM.Alpha_Emp_Code=ISNULL(@emp_code,EM.Alpha_Emp_Code) or EM.Emp_First_Name like ISNULL(@emp_code,EM.Emp_First_Name))	
	--and ISNULL(I.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	--AND ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),',') ) 
	--AND ISNULL(I.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(I.Desig_ID,0)),',') ) 

	SELECT EM.Emp_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name)Emp_Full_Name,Answer,EM.Alpha_Emp_Code,Response_Date,SurveyEmp_Id
	INTO #FINAL_EMP
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON SR.Emp_Id=EM.Emp_ID 
	INNER JOIN V0080_EMP_MASTER_INCREMENT_GET I ON I.Emp_ID = EM.Emp_ID 
	WHERE  Survey_Id = @Survey_Id AND (EM.Alpha_Emp_Code=ISNULL(@emp_code,EM.Alpha_Emp_Code) or EM.Emp_First_Name like ISNULL(@emp_code,EM.Emp_First_Name))	
	and ISNULL(I.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	AND ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),',') ) 
	AND ISNULL(I.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(I.Desig_ID,0)),',') ) 
	

	insert into #tempTable
	(Survey_Id,Survey_Question,Survey_Type,Sorting_No,SurveyQuestion_Id,SubQuestion,Is_Mandatory)
	(Select Survey_ID,Survey_Question,Survey_Type,Sorting_No,SurveyQuestion_Id,SubQuestion,Is_Mandatory
	from T0052_SurveyTemplate WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Survey_ID=@Survey_Id)
	--select * from #tempTable
	DECLARE cur CURSOR
	FOR 
	   SELECT SurveyQuestion_Id FROM #tempTable --where SurveyQuestion_Id=76
		open cur
			FETCH NEXT FROM cur INTO @col1
			WHILE @@FETCH_STATUS = 0
			   BEGIN		
			  -- select @col1,@Survey_Id,@Emp_Id	
					
					UPDATE #tempTable
					SET SurveyEmp_Id = S.SurveyEmp_Id ,Emp_Id=s.Emp_Id,Answer=s.Answer,Response_Date=s.Response_Date
					FROM (Select SR.SurveyEmp_Id,SR.Emp_Id,REPLACE(SR.Answer,'~~','#')Answer,SR.Response_Date from T0060_SurveyEmployee_Response SR WITH (NOLOCK)
					INNER JOIN #FINAL_EMP EM ON EM.EMP_ID=SR.EMP_ID where SR.Emp_Id=@Emp_Id and SR.Survey_Id=@Survey_Id and SR.SurveyQuestion_Id = @col1) S 
					where Survey_Id = @Survey_Id and SurveyQuestion_Id = @col1

					--UPDATE #tempTable
					--SET SurveyEmp_Id = SR.SurveyEmp_Id ,Emp_Id=SR.Emp_Id,Answer=SR.Answer,Response_Date=SR.Response_Date
					--  	 FROM #FINAL_EMP SR
					--	 WHERE SR.Emp_Id=@Emp_Id and SurveyQuestion_Id = @col1
					
					FETCH NEXT FROM cur INTO @col1
			   END
	   close cur
	   deallocate cur
	  -- select * from #tempTable
	 --
	
	 SELECT ROW_NUMBER() OVER (PARTITION BY SubQuestion ORDER BY Sorting_No)as SrNo,
	 Survey_Id,Survey_Question,Survey_Type,Sorting_No,SurveyQuestion_Id,SurveyEmp_Id,Emp_Id,
	isnull(Answer,'') as Answer,Response_Date,SubQuestion,Is_Mandatory from #tempTable order by Sorting_No
	drop table #tempTable
END
