-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 12/06/2023
-- Description:	Get Template Preview Data
-- =============================================
CREATE PROCEDURE [dbo].[GetTemplate_EmpResponse_BackupDivyaraj01112023]
	@T_ID		numeric(18,0)
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
		 T_ID				numeric(18,0)	
		,Field_Name		nvarchar(500)
		,Field_Type			varchar(50)	
		,Sorting_No				int	
		,F_ID		numeric(18,0)
		,EmpId			numeric(18,0)
		,Emp_Id					numeric(18,0)
		,Answer					nvarchar(max)
		,Created_Date			datetime		
		,Is_Required			int
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

	SELECT EM.Emp_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name)Emp_Full_Name,Answer,EM.Alpha_Emp_Code,Created_Date
	INTO #FINAL_EMP
	FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN T0100_Employee_Template_Response SR WITH (NOLOCK) ON SR.Emp_Id=EM.Emp_ID 
	INNER JOIN V0080_EMP_MASTER_INCREMENT_GET I ON I.Emp_ID = EM.Emp_ID 
	WHERE  T_Id = @T_ID AND (EM.Alpha_Emp_Code=ISNULL(@emp_code,EM.Alpha_Emp_Code) or EM.Emp_First_Name like ISNULL(@emp_code,EM.Emp_First_Name))	
	and ISNULL(I.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	AND ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),',') ) 
	AND ISNULL(I.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(I.Desig_ID,0)),',') ) 
	

	insert into #tempTable
	(T_ID,Field_Name,Field_Type,Sorting_No,F_ID,Is_Required)	
	(Select T_ID,Field_Name,Field_Type,Sorting_No,F_ID,Is_Required
	from T0050_Template_Field_Master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and T_ID=@T_ID)
	
	select * from #FINAL_EMP
	select * from #tempTable
	--return

	DECLARE cur CURSOR
	FOR 
	   SELECT F_ID FROM #tempTable --where SurveyQuestion_Id=76
		open cur
			FETCH NEXT FROM cur INTO @col1
			WHILE @@FETCH_STATUS = 0
			   BEGIN		
			  -- select @col1,@Survey_Id,@Emp_Id	
					
					UPDATE #tempTable
					SET Emp_Id = S.Emp_Id ,Answer=S.Answer,Created_Date=S.Created_Date
					FROM (Select TR.Emp_Id,REPLACE(TR.Answer,'~~','#')Answer,TR.Created_Date from T0100_Employee_Template_Response TR WITH (NOLOCK)
					INNER JOIN #FINAL_EMP EM ON EM.EMP_ID=TR.EMP_ID where TR.Emp_Id=@Emp_Id and TR.T_Id=@T_ID and TR.F_Id = @col1) S 
					where T_ID = @T_ID and F_ID = @col1

					--UPDATE #tempTable
					--SET SurveyEmp_Id = SR.SurveyEmp_Id ,Emp_Id=SR.Emp_Id,Answer=SR.Answer,Response_Date=SR.Response_Date
					--  	 FROM #FINAL_EMP SR
					--	 WHERE SR.Emp_Id=@Emp_Id and SurveyQuestion_Id = @col1
					
					FETCH NEXT FROM cur INTO @col1
			   END
	   close cur
	   deallocate cur
	  
	  select * from #tempTable
	  return
	
	-- SELECT ROW_NUMBER() OVER (PARTITION BY SubQuestion ORDER BY Sorting_No)as SrNo,
	-- Survey_Id,Survey_Question,Survey_Type,Sorting_No,SurveyQuestion_Id,SurveyEmp_Id,Emp_Id,
	--isnull(Answer,'') as Answer,Response_Date,SubQuestion,Is_Mandatory from #tempTable order by Sorting_No

	SELECT ROW_NUMBER() OVER (ORDER BY Sorting_No)as SrNo,
	 T_ID,Field_Name,Field_Type,Sorting_No,F_ID,EmpId,Emp_Id,
	isnull(Answer,'') as Answer,Created_Date,Is_Required 
	from #tempTable order by Sorting_No
	drop table #tempTable
END
