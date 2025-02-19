CREATE PROCEDURE [dbo].[P_Survey_Employee_Details]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''	
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Survey_Id INT	
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
		 survey_id			numeric(18,0)
		,SurveyQuestion_Id	numeric(18,0)
		,Emp_id				numeric(18,0)
		,Employee_Code		varchar(50)
		,Employee_Name		varchar(100)
		,Answer				nvarchar(MAX)
		,Survey_Type		varchar(500)
		,survey_Question	NVARCHAR(MAX)
		,sorting_no			INT
		,Is_Filled	VARCHAR(10)
		,IMEI_NO	varchar(250)
		,Response_Date varchar(25)
		,Passing_Critera int
		,Total_Score float		
		,Final_Result varchar(100)
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
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    
	
	DECLARE @srv_branch_id int
	DECLARE @Survey_EmpId VARCHAR(max)
	DECLARE @srv_desig_id VARCHAR(max)
		set @srv_branch_id=0
		set @Survey_EmpId=''
		set @srv_desig_id=''
	
	Select @srv_branch_id=isnull(branch_id,0),@Survey_EmpId=ISNULL(Survey_EmpId,''),
		   @srv_desig_id=ISNULL(desig_id,'')
	from T0050_SurveyMaster WITH (NOLOCK) where Survey_Id = @Survey_Id
	--select * from #Emp_Cons
	--select @srv_branch_id,@Survey_EmpId,@srv_desig_id
	if @Survey_EmpId <> ''
		BEGIN
			INSERT INTO #EMP_DETAILS		
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND EI.Emp_ID IN(select cast(data as varchar(max)) from dbo.Split (@Survey_EmpId,'#') WHERE DATA <> '')
		END
	ELSE IF @srv_branch_id > 0
		BEGIN
			INSERT INTO #EMP_DETAILS
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND ISNULL(EI.Branch_ID,0)=@srv_branch_id
		END 
	ELSE IF @srv_desig_id <> ''
		BEGIN
			INSERT INTO #EMP_DETAILS
			SELECT DISTINCT Alpha_Emp_Code,EI.Emp_ID,Emp_Full_Name,Branch_Name,Desig_Name,Dept_Name,Emp_Superior,EI.Mobile_No,EI.Home_Tel_no,EI.Old_Ref_No
			FROM V0080_EMP_MASTER_INCREMENT_GET EI
			INNER JOIN #Emp_Cons E ON EI.EMP_ID=E.Emp_ID
			where CMP_ID=@CMP_ID AND Desig_Id IN(select cast(data as varchar(max)) from dbo.Split (@srv_desig_id,'#') WHERE DATA <> '')
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
	
	INSERT INTO #Table2(Answer,survey_id,SurveyQuestion_Id,Survey_Type,Emp_id,Employee_Code,Employee_Name,survey_Question,sorting_no,Is_Filled,IMEI_NO,Response_Date,Passing_Critera)						
	SELECT DISTINCT REPLACE(REPLACE(REPLACE(SR.Answer, CHAR(13), ''), CHAR(10), ''),'\n',''),SR.Survey_Id,SR.SurveyQuestion_Id,T.Survey_Type,E.Emp_Id, E.Alpha_Emp_Code ,E.Emp_Full_Name as EmployeeName,
	left(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(t.survey_Question,'[',''),']',''), CHAR(13), ''), CHAR(10), ''),'\n',''),128),T.Sorting_No,'',EID.IMEI_No,Response_Date,ISNULL(Min_Passing_Criteria,0)
	FROM #EMP_DETAILS E
	INNER JOIN T0050_SurveyMaster SM WITH (NOLOCK) ON SM.Survey_ID=@Survey_Id
	LEFT JOIN(SELECT IMEI_NO,Emp_ID FROM T0095_Emp_IMEI_Details EI WITH (NOLOCK)
	WHERE TRAN_ID=(SELECT MAX(Tran_ID) FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID=EI.Emp_ID))EID ON EID.Emp_ID=E.EMP_ID
	LEFT JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON E.Emp_ID = SR.Emp_Id   and  SR.Survey_Id = @Survey_Id
	LEFT JOIN T0052_SurveyTemplate T WITH (NOLOCK) ON  T.Survey_Id = SR.Survey_Id AND SR.SurveyQuestion_Id = T.SurveyQuestion_Id
	and  SR.Survey_Id = @survey_id--and e.emp_id=1511 --and (Survey_Type='Text' OR Survey_Type='Paragraph Text')
	order by T.sorting_no -- Added by Deepali -20Jul22
	
	--SELECT DISTINCT 333,* FROM #Table2 ORDER BY Emp_ID
	
	--ALTER TABLE #Table2 ADD Row_ID INT
	
	--UPDATE	T
	--SET		ROW_ID = T1.ROW_ID
	--FROM	#Table2 T
	--		INNER JOIN  (SELECT	ROW_NUMBER() OVER(PARTITION BY survey_Question ORDER BY survey_Question,Employee_Code) AS ROW_ID, Emp_id,SurveyQuestion_Id
	--					 FROM	#Table2 where Employee_Code is NOT NULL) T1 ON T.Emp_id=T1.Emp_id AND T.SurveyQuestion_Id=T1.SurveyQuestion_Id
	
	--select * from #Survey_Qusetion
	--select DISTINCT Case When Row_id > 1 Then survey_Question Else '' End As survey_Question,sorting_no
	--INTO #Survey_Qusetion
	--from #Table2 
	--
	--select * from #Survey_Qusetion
	
	UPDATE #Table2 
	SET Is_filled = #Table2.Emp_id
	FROM (
		SELECT Emp_Id,Survey_Id
		FROM T0060_SurveyEmployee_Response WITH (NOLOCK)) i
	WHERE 
		i.Emp_Id = #Table2.Emp_Id and i.Survey_Id=#Table2.Survey_Id and i.Survey_Id=@Survey_id
	
	CREATE TABLE #Table3
	(
		Emp_ID			  INT,
		SurveyQuestion_Id INT,
		Question		  NVarchar(MAX),
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
	DECLARE @SurveyQuestion_Id INT


	--SELECT SE.Emp_ID,ST.SurveyQuestion_Id,Survey_Question,ST.Answer,SE.Answer,ST.Marks,
	--CASE WHEN (UPPER(ST.Answer)=UPPER(SE.Answer)) THEN ST.Marks 
	--WHEN (CHARINDEX('#',ST.Answer) = 0 and CHARINDEX(SE.Answer,ST.Answer) > 0) THEN ST.Marks  ELSE 0 END,
	--(LEN(ST.Answer) - LEN(REPLACE(ST.Answer,'#','')) + 1) ,(LEN(SE.Answer) - LEN(REPLACE(SE.Answer,'#','')) + 1) ,
	--case when CHARINDEX('#',SE.Answer) > 0 then 1 ELSE 0 END
	--from T0052_SurveyTemplate ST
	--INNER JOIN T0060_SurveyEmployee_Response SE ON ST.SurveyQuestion_Id=SE.SurveyQuestion_Id	
	--INNER JOIN #Emp_Cons E ON SE.EMP_ID=E.Emp_ID	
	--WHERE ST.Survey_Id=@survey_id and st.SurveyQuestion_Id in(50,51)

	INSERT INTO #Table3
	SELECT SE.Emp_ID,ST.SurveyQuestion_Id,Survey_Question,ST.Answer,SE.Answer,ST.Marks,
	CASE WHEN (UPPER(ST.Answer)=UPPER(SE.Answer)) THEN ST.Marks 
	WHEN (CHARINDEX('#',ST.Answer) = 0 and CHARINDEX(SE.Answer,ST.Answer) > 0) THEN ST.Marks  ELSE 0 END,
	(LEN(ST.Answer) - LEN(REPLACE(ST.Answer,'#','')) + 1) ,(LEN(SE.Answer) - LEN(REPLACE(SE.Answer,'#','')) + 1) ,
	case when CHARINDEX('#',SE.Answer) > 0 then 1 ELSE 0 END
	from T0052_SurveyTemplate ST WITH (NOLOCK)
	INNER JOIN T0060_SurveyEmployee_Response SE WITH (NOLOCK) ON ST.SurveyQuestion_Id=SE.SurveyQuestion_Id
	--and CHARINDEX('#' + CAST(SE.Answer AS VARCHAR(10)) + '#', '#' + ST.Answer + '#') > 0
	--AND CHARINDEX(@col1,Answer ) > 0 		
	--and exists(select CAST(DATA  AS varchar(500)) from dbo.Split(SE.Answer, '#') PB Where pb.Data=
	--cast(@col1 as varchar(500)) 	
	--(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
	INNER JOIN #Emp_Cons E ON SE.EMP_ID=E.Emp_ID
	--CROSS APPLY STRING_SPLIT(ST.Answer, '#')
	--CROSS APPLY (select CAST(DATA  AS varchar(500)) from dbo.Split(ST.Answer, '#') PB1)
	WHERE ST.Survey_Id=@survey_id
	order by ST.sorting_no -- Added by Deepali -20Jul22
	
	--insert into #Table1 (Question_Option)
	--select  CAST(DATA  AS nvarchar(800)) from dbo.Split (@optionstr,'#')  			
	
	--UPDATE #Table3 
	--SET Emp_Marks = #Table3.Actual_Marks
	--FROM (
	--	SELECT Emp_Id,Actual_Answer,Emp_Answer,Actual_Marks
	--	FROM #Table3 WHERE CHARINDEX(Emp_Answer,Actual_Answer) > 0)i
	--WHERE 
	--	i.Emp_Id = #Table3.Emp_Id 

		--select * from #Table3
	--SELECT * from #Table2 order by Emp_id	
	--select Actual_Answer from #Table3 where CHARINDEX(Actual_Answer,'#') > 0	

	--UPDATE #Table3 SET Emp_Marks=@Actual_Marks
	--WHERE ISNULL(Actual_Count,0)=ISNULL(Emp_Count,0)

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
				select Actual_Answer,Emp_Answer,Emp_ID,SurveyQuestion_Id,Actual_Marks from #Table3 where Actual_Count=Emp_Count AND MultiChoice=1
			open cur
				fetch next from cur into @Actual_Answer,@Emp_Answer,@Emp_ID,@SurveyQuestion_Id,@Actual_Marks
				while @@FETCH_STATUS = 0
					Begin
							INSERT INTO #Table4
							SELECT distinct CAST(DATA  AS nvarchar(1200))							
							from dbo.Split (@Emp_Answer,'#')

							--SELECT * FROM #Table4
							SET @CTR=0

							declare cur1 cursor
							for 
							select distinct  Emp_Answer,@SurveyQuestion_Id from #Table4 
								open cur1
									fetch next from cur1 into @col1,@col2
									while @@FETCH_STATUS = 0
										Begin
											select @act_result= count(1) from #Table4 
											
											IF EXISTS(SELECT 1 FROM #Table3 WHERE EMP_ID=@EMP_ID 
													  AND SurveyQuestion_Id=@SurveyQuestion_Id AND CHARINDEX(@col1,Actual_Answer) > 0)
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
									WHERE Emp_ID=@Emp_ID AND SurveyQuestion_Id=@SurveyQuestion_Id
								ELSE IF @result=0
									UPDATE #Table3 SET Emp_Marks=0
									WHERE Emp_ID=@Emp_ID AND SurveyQuestion_Id=@SurveyQuestion_Id

						fetch next from cur into  @Actual_Answer,@Emp_Answer,@Emp_ID,@SurveyQuestion_Id,@Actual_Marks
					End
			close cur
			deallocate cur
		
		--
		
		
		UPDATE #Table2
		SET Total_Score = I.TOT_SCORE,Final_Result = CASE WHEN TOT_SCORE >=Passing_Critera   THEN 'PASS' ELSE 'FAIL' END 
		FROM (
			SELECT SUM(Emp_Marks)TOT_SCORE,Emp_ID
			FROM #Table3 GROUP BY Emp_ID) i
		WHERE 
			i.Emp_Id = #Table2.Emp_Id 

			--SELECT * FROM #Table2
		--UPDATE #Table2
		--SET Final_Result = CASE WHEN Passing_Critera >= Total_Score THEN 'PASS' ELSE 'FAIL' END 
	

	--SELECT @columns = COALESCE(@columns + ',', '') + '[' + CAST(REPLACE(REPLACE(survey_Question,'[',''),']','') AS nvarchar(MAX)) + ']'
	--FROM #Table2 where survey_Question <> ''	
	--GROUP BY survey_Question,sorting_no ORDER by sorting_no


	--Start Added by Niraj (14072022)
	SELECT  @columns = STUFF((SELECT distinct ','+COALESCE(@columns + ',', '') + '[' + CAST(REPLACE(REPLACE(survey_Question,'[',''),']','') AS nvarchar(MAX)) + ']' 
			FROM #Table2 where survey_Question <> ''	
			GROUP BY sorting_no,survey_Question 
			--ORDER by sorting_no -- added by Deepali - 19July2022
          FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)') 
    ,1,1,'')
	--End Added by Niraj (14072022)

	SET @query = 'SELECT ROW_NUMBER() OVER (ORDER BY Employee_Code) AS ''Sr.No.'',emp_id,Employee_Code as Alpha_Emp_Code,''="'' +Employee_Code +''"'' as Employee_Code,mobile_no,Old_Refrence_Code,Employee_Name as Emp_Full_name,Employee_Name,Emergency_Contact,Branch_Name,Dept_Name as Department,Desig_Name as Designation,mobile_no as Personal_Contact,IMEI_NO,EMP_FULL_NAME AS Manager,
			      CASE WHEN IS_FILLED <> '''' THEN ''Yes'' else ''No'' end as Survey_Completion_Status,Response_Date,'+ @columns +',Total_Score,Final_Result
						FROM (
							SELECT survey_Question,Employee_Code,ed.mobile_no,Emergency_Contact,Employee_Name,Answer,sv.Emp_ID,Old_Refrence_Code,Branch_Name,Dept_Name,Desig_Name,RM.EMP_FULL_NAME,IS_FILLED,IMEI_NO,Response_Date,Total_Score,Final_Result
							FROM #Table2 SV
							INNER JOIN #EMP_DETAILS ED ON ED.EMP_ID=SV.EMP_ID	
							LEFT JOIN T0080_EMP_MASTER RM WITH (NOLOCK) ON RM.EMP_ID=	ED.Emp_superior	
							) as s
						PIVOT
						(						 
							Max(Answer)
							FOR [survey_Question] IN (' + @columns + ') 						
						)AS T where  isnull(Employee_Code,'''')<>'''' ' 
			print @query
			
			EXEC(@query)
END
