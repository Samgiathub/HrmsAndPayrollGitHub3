-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 12/01/2024
-- Description:	To Get the Template Application shows to Reporting Manager
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_TemplateApplication_Data_OLD]
	@From_Date		Datetime,--nvarchar(20)='',
	@To_Date 		Datetime,--nvarchar(20)='',
	@Cmp_Id		NUMERIC,  
	@Desig_ID		varchar(Max), 
	@Emp_ID		numeric  = 0,
	@T_Id INT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		
	DECLARE @columns nVARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )              
	
	CREATE TABLE #Table2
	(
		 T_ID			numeric(18,0)
		,F_ID	numeric(18,0)
		,Emp_id				numeric(18,0)
		,Employee_Code		varchar(50)
		,Employee_Name		varchar(100)
		,Answer				nvarchar(MAX)
		,Field_Type		varchar(500)
		,Field_Name	NVARCHAR(MAX)
		,sorting_no			INT
		,Is_Filled	VARCHAR(10)
		,IMEI_NO	varchar(250)
		,Created_Date varchar(25)
		--,Response_Flag int
		--,Passing_Critera int
		--,Total_Score float		
		--,Final_Result varchar(100)
	)
	
	CREATE TABLE #EMP_DETAILS
	(
		Alpha_Emp_Code VARCHAR(250),
		Emp_ID INT,
		Emp_Full_Name VARCHAR(250),
		Branch_Name VARCHAR(250),
		Desig_Name VARCHAR(250),
		Dept_Name VARCHAR(250),
		Emp_Superior VARCHAR(250),
		mobile_no VARCHAR(25),
		Emergency_Contact VARCHAR(25),
		--Segment_Name VARCHAR(250),
		Old_Refrence_Code VARCHAR(25)		
	)
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,'0','0','0','0','0',@Desig_ID,@Emp_ID,'',0,0,'0','0','0','0',0,0,0,'',0,0,0    
	
	DECLARE @tmp_branch_id int
	DECLARE @tmp_EmpId VARCHAR(max)
	DECLARE @tmp_desig_id VARCHAR(max)
		set @tmp_branch_id=0
		set @tmp_EmpId=''
		set @tmp_desig_id=''
	
	Select @tmp_branch_id=isnull(branch_id,0),@tmp_EmpId=ISNULL(EmpId,''),
		   @tmp_desig_id=ISNULL(desig_id,'')
	from T0040_Template_Master WITH (NOLOCK) where T_ID = @T_id
	--select * from #Emp_Cons
	--select @srv_branch_id,@Survey_EmpId,@srv_desig_id
	if @tmp_EmpId <> ''
		BEGIN
			INSERT INTO #EMP_DETAILS		
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND EI.Emp_ID IN(select cast(data as varchar(max)) from dbo.Split (@tmp_EmpId,'#') WHERE DATA <> '')
		END
	ELSE IF @tmp_branch_id > 0
		BEGIN
			INSERT INTO #EMP_DETAILS
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND ISNULL(EI.Branch_ID,0)=@tmp_branch_id
		END 
	ELSE IF @tmp_desig_id <> ''
		BEGIN
			INSERT INTO #EMP_DETAILS
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND Desig_Id IN(select cast(data as varchar(max)) from dbo.Split (@tmp_desig_id,'#') WHERE DATA <> '')
		END		
	ELSE
		BEGIN		
			INSERT INTO #EMP_DETAILS		
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID 
		END
	--SELECT * FROM #EMP_DETAILS
	
	INSERT INTO #Table2(Answer,T_ID,F_ID,Field_Type,Emp_id,Employee_Code,Employee_Name,Field_Name,sorting_no,Is_Filled,IMEI_NO,Created_Date)						
	SELECT DISTINCT REPLACE(REPLACE(REPLACE(TR.Answer, CHAR(13), ''), CHAR(10), ''),'\n',''),TR.T_Id,TR.F_Id,TF.Field_Type,E.Emp_Id, E.Alpha_Emp_Code ,E.Emp_Full_Name as EmployeeName,
	left(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TF.Field_Name,'[',''),']',''), CHAR(13), ''), CHAR(10), ''),'\n',''),128),TF.Sorting_No,'',EID.IMEI_No,Created_Date
	--,TR.Response_Flag
	FROM #EMP_DETAILS E
	INNER JOIN T0040_Template_Master TM WITH (NOLOCK) ON TM.T_ID=@T_Id
	LEFT JOIN(SELECT IMEI_NO,Emp_ID FROM T0095_Emp_IMEI_Details EI WITH (NOLOCK)
	WHERE TRAN_ID=(SELECT MAX(Tran_ID) FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID=EI.Emp_ID))EID ON EID.Emp_ID=E.EMP_ID
	LEFT JOIN T0100_Employee_Template_Response TR WITH (NOLOCK) ON E.Emp_ID = TR.Emp_Id   and  TR.T_Id = @T_Id
	LEFT JOIN T0050_Template_Field_Master TF WITH (NOLOCK) ON  TF.T_ID = TR.T_Id AND TR.F_Id = TF.F_ID
	and  TR.T_Id = @T_Id--and e.emp_id=1511 --and (Survey_Type='Text' OR Survey_Type='Paragraph Text')
	--and TR.Created_Date between @From_Date and @To_Date
	order by TF.sorting_no 
	
	UPDATE #Table2 
	SET Is_filled = #Table2.Emp_id
	FROM (
		SELECT Emp_Id,T_Id
		FROM T0100_Employee_Template_Response WITH (NOLOCK)) i
	WHERE 
		i.Emp_Id = #Table2.Emp_Id and i.T_Id=#Table2.T_ID and i.T_Id=@T_Id
	
	CREATE TABLE #Table3
	(
		Emp_ID			  INT,
		F_Id			 INT,
		Field_Name		  NVarchar(MAX),
		Actual_Answer	  NVarchar(MAX),
		Emp_Answer		  NVarchar(MAX),
		Actual_Marks	  float,
		Emp_Marks		  float,
		Actual_Count	int,
		Emp_Count		int,
		MultiChoice		bit
	)
	DECLARE @Actual_Answer NVarchar(MAX)
	DECLARE @Emp_Answer NVarchar(MAX)
	DECLARE @Emp_ID1 INT
	DECLARE @F_Id INT

	--INSERT INTO #Table3
	--SELECT TR.Emp_ID,TF.F_ID,Field_Name,TR.Answer,
	--CASE WHEN (UPPER(TR.Answer)=UPPER(TR.Answer)) THEN ST.Marks 
	--WHEN (CHARINDEX('#',ST.Answer) = 0 and CHARINDEX(SE.Answer,ST.Answer) > 0) THEN ST.Marks  ELSE 0 END,
	--(LEN(ST.Answer) - LEN(REPLACE(ST.Answer,'#','')) + 1) ,(LEN(SE.Answer) - LEN(REPLACE(SE.Answer,'#','')) + 1) ,
	--case when CHARINDEX('#',SE.Answer) > 0 then 1 ELSE 0 END
	--from T0050_Template_Field_Master TF WITH (NOLOCK)
	--INNER JOIN T0100_Employee_Template_Response TR WITH (NOLOCK) ON ST.SurveyQuestion_Id=SE.SurveyQuestion_Id
	----and CHARINDEX('#' + CAST(SE.Answer AS VARCHAR(10)) + '#', '#' + ST.Answer + '#') > 0
	----AND CHARINDEX(@col1,Answer ) > 0 		
	----and exists(select CAST(DATA  AS varchar(500)) from dbo.Split(SE.Answer, '#') PB Where pb.Data=
	----cast(@col1 as varchar(500)) 	
	----(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	--INNER JOIN #Emp_Cons E ON SE.EMP_ID=E.Emp_ID
	----CROSS APPLY STRING_SPLIT(ST.Answer, '#')
	----CROSS APPLY (select CAST(DATA  AS varchar(500)) from dbo.Split(ST.Answer, '#') PB1)
	--WHERE ST.Survey_Id=@survey_id
	--order by ST.sorting_no -- Added by Deepali -20Jul22
	
	CREATE TABLE #Table4
	(
	Emp_Answer NVARCHAR(500),
	--Emp_ID INT,
	--SurveyQuestion_Id INT
	)
	DECLARE @col1 VARCHAR(500)
	DECLARE @col2 INT
	DECLARE @result INT
	DECLARE @act_result INT
	DECLARE @CTR AS INT
	DECLARE @Actual_Marks FLOAT
	--select * from #Table3
		declare cur cursor
			for 
				select Actual_Answer,Emp_Answer,Emp_ID,F_Id,Actual_Marks from #Table3 where Actual_Count=Emp_Count AND MultiChoice=1
			open cur
				fetch next from cur into @Actual_Answer,@Emp_Answer,@Emp_ID,@F_Id,@Actual_Marks
				while @@FETCH_STATUS = 0
					Begin
							INSERT INTO #Table4
							SELECT distinct CAST(DATA  AS nvarchar(1200))							
							from dbo.Split (@Emp_Answer,'#')

							--SELECT * FROM #Table4
							SET @CTR=0

							declare cur1 cursor
							for 
							select distinct  Emp_Answer,@F_Id from #Table4 
								open cur1
									fetch next from cur1 into @col1,@col2
									while @@FETCH_STATUS = 0
										Begin
											select @act_result= count(1) from #Table4 
											
											IF EXISTS(SELECT 1 FROM #Table3 WHERE EMP_ID=@EMP_ID 
													  AND F_Id=@F_Id AND CHARINDEX(@col1,Actual_Answer) > 0)
												BEGIN	
													SET @result=1
													SET @CTR+=1
												END
											ELSE
												BEGIN
													SET @result=0													
													--RETURN
												END

											--SET @CTR+=1
											fetch next from cur1 into @col1,@col2
										End
								close cur1
								deallocate cur1	
								
								--SELECT * FROM #Table3

								IF @act_result=@CTR	AND @result=1										
									UPDATE #Table3 SET Emp_Marks=@Actual_Marks
									WHERE Emp_ID=@Emp_ID AND F_Id=@F_Id
								ELSE IF @result=0
									UPDATE #Table3 SET Emp_Marks=0
									WHERE Emp_ID=@Emp_ID AND F_Id=@F_Id

						fetch next from cur into  @Actual_Answer,@Emp_Answer,@Emp_ID,@F_Id,@Actual_Marks
					End
			close cur
			deallocate cur
		
		--
		
		
		--UPDATE #Table2
		--SET Total_Score = I.TOT_SCORE,Final_Result = CASE WHEN TOT_SCORE >=Passing_Critera   THEN 'PASS' ELSE 'FAIL' END 
		--FROM (
		--	SELECT SUM(Emp_Marks)TOT_SCORE,Emp_ID
		--	FROM #Table3 GROUP BY Emp_ID) i
		--WHERE 
		--	i.Emp_Id = #Table2.Emp_Id 

		--Select * from EMP_DETAILS
		--Select * From #Table2		
		--Select * from #Table3
		--Select * from #Table4
		--return

	--SELECT  @columns = STUFF((SELECT distinct ','+COALESCE(@columns + ',', '') + '[' + CAST(REPLACE(REPLACE(Field_Name,'[',''),']','') AS nvarchar(MAX)) + ']' 
	--		FROM #Table2 where Field_Name <> ''	
	--		GROUP BY sorting_no,Field_Name					
 --         FOR XML PATH(''), TYPE
 --       ).value('.', 'NVARCHAR(MAX)') 
 --   ,1,1,'')

 SELECT @columns = STUFF((SELECT ',' + COALESCE(@columns + ',', '') + '[' + CAST(REPLACE(REPLACE(Field_Name, '[', ''), ']', '') AS NVARCHAR(MAX)) + ']'
    FROM (
        SELECT DISTINCT sorting_no, Field_Name -- Use DISTINCT within a subquery
        FROM #Table2
        WHERE Field_Name <> ''
    ) AS subquery
    ORDER BY sorting_no, Field_Name -- Perform ORDER BY within the subquery
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	
	SET @query = 'SELECT ROW_NUMBER() OVER (ORDER BY Employee_Code) AS ''Sr.No.'',emp_id,Employee_Code as Alpha_Emp_Code,mobile_no,Old_Refrence_Code,Employee_Name as Emp_Full_name,Employee_Name,Emergency_Contact as Home_Telephone,Branch_Name,Dept_Name as Department,Desig_Name as Designation,mobile_no as Personal_Mobile_No,IMEI_NO,EMP_FULL_NAME AS Manager,
			      CASE WHEN IS_FILLED <> '''' THEN ''Yes'' else ''No'' end as Template_Completion_Status,Created_Date,'+ @columns +'
						FROM (
								SELECT ROW_NUMBER() OVER (PARTITION BY Employee_Code, Field_Name ORDER BY Created_Date) AS RowNum,Field_Name,Employee_Code,
								ed.mobile_no,Emergency_Contact,Employee_Name,Answer,sv.Emp_ID,Old_Refrence_Code,Branch_Name,Dept_Name,Desig_Name,
								RM.EMP_FULL_NAME,IS_FILLED,IMEI_NO,Created_Date
								FROM #Table2 SV
								INNER JOIN #EMP_DETAILS ED ON ED.EMP_ID = SV.EMP_ID
								LEFT JOIN T0080_EMP_MASTER RM WITH (NOLOCK) ON RM.EMP_ID = ED.Emp_superior
								where convert(datetime,SV.Created_Date,112) between ''' + Convert(nvarchar,@From_Date,112) + ''' and  ''' + Convert(nvarchar,@To_Date,112) + '''
							) as s
					PIVOT
						(						 
							Max(Answer)
							FOR [Field_Name] IN (' +@columns + ') 						
						)AS T where  isnull(Employee_Code,'''')<>'''' ' 
			print @query
			
			EXEC(@query)	

			--PIVOT
			--			(						 
			--				Max(Answer)
			--				FOR [Field_Name] IN (' + @columns + ') 						
			--			)AS T where  isnull(Employee_Code,'''')<>''''
END
