Create PROCEDURE [dbo].[Rpt_SurveyAnalysis_Backup_10012025]
	 @Cmp_Id		numeric(18,0)
	,@Survey_Id		numeric(18,0)
	,@flag			int = 0
	,@Emp_ID		int=0
	,@emp_code		varchar(200)=''
	,@Branch_Id		VARCHAR(MAX) = ''
	,@Desig_Id		VARCHAR(MAX) = ''
	,@Dept_Id		VARCHAR(MAX) = ''
	,@String_Name	VARCHAR(MAX) = ''
AS
BEGIN

	SET	 NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @Branch_Id='0' OR @Branch_Id=''
		SET @Branch_Id=NULL
	IF @Desig_Id='0' OR @Desig_Id=''
		SET @Desig_Id=NULL
	IF @Dept_Id='0' OR @Dept_Id=''
		SET @Dept_Id=NULL
	IF @emp_code=''
		SET @emp_code=NULL

			SELECT Distinct EM.Emp_ID,EM.Emp_Full_Name,Answer,EM.Alpha_Emp_Code,Response_Date,SurveyEmp_Id,SurveyQuestion_Id,em.Mobile_No,Branch_Name,Desig_Name,Dept_Name
			INTO #FINAL_EMP
			FROM T0080_EMP_MASTER EM WITH (NOLOCK)
			INNER JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON SR.Emp_Id=EM.Emp_ID 
			INNER JOIN V0080_EMP_MASTER_INCREMENT_GET I ON I.Emp_ID = EM.Emp_ID 
			WHERE  Survey_Id = @Survey_Id AND (EM.Alpha_Emp_Code=ISNULL(@emp_code,EM.Alpha_Emp_Code) or EM.Emp_First_Name like ISNULL(@emp_code,EM.Emp_First_Name))
			and ISNULL(I.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)),',') ) 
			AND ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),',') ) 
			AND ISNULL(I.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(I.Desig_ID,0)),',') ) 
	
		CREATE TABLE #Table2
			(
				survey_id			numeric(18,0)
				,SurveyQuestion_Id	numeric(18,0)
				,Emp_id				numeric(18,0)
				,Employee_Code		varchar(50)
				,Employee_Name		varchar(150)
				,Answer				nvarchar(1500) -- changed by Deepali 1July22
				,Survey_Type		nvarchar(50)  -- changed by Deepali 1July22
				,survey_Question	nVARCHAR(1500)  -- changed by Deepali 1July22
				,Response_Date		varchar(15)
				,Mobile_No			varchar(20)
				,IMEI_NO			varchar(250)
				,Survey_Title nvarchar(500)		-- changed by Deepali 1July22
				,SurveyStart_Date varchar(15)		
				,Survey_OpenTill varchar(15)		
			)
IF @flag = 2 
	BEGIN
			create table #Table1
			(
				 Question_Option	nvarchar(1500)
				,Response			numeric(18,2)	
				,Res_Count			numeric(18,0)
				,Emp_id				numeric(18,0)
				,survey_id			numeric(18,0)
				,SurveyQuestion_Id	numeric(18,0)
				,Survey_Type		nvarchar(50) -- changed by Deepali 1July22
				--,ANSWER				varchar(2000)
			)				
			declare @optionstr as nvarchar(1500) 
			set @optionstr = ''
			declare @col1 as nvarchar(1200)
			declare @tot_cnt as int
			declare @res_cnt as int
			declare @empid as numeric(18,0)
			declare @col2 as numeric(18,0)
			declare @chkcnt as numeric(18,0)
			set @chkcnt = 0
			DECLARE @Answer AS nVARCHAR(2000)
			declare @SurveyQuestion_Id	numeric(18,0)
			declare @Survey_Type		nvarchar(50)	-- changed by Deepali 1July22
			
			declare cur1 cursor
			for 
				Select SurveyQuestion_Id,Survey_Type from T0052_SurveyTemplate WITH (NOLOCK) where Survey_Type not in('Text','Paragraph Text') and survey_id = @Survey_Id order by Sorting_No
			open cur1
				fetch next from cur1 into @SurveyQuestion_Id,@Survey_Type
				while @@FETCH_STATUS = 0
				Begin
					--If @Survey_Type = 'Radiobutton List' or @Survey_Type='DropdownList' or @Survey_Type='CheckBoxList' or @Survey_Type='Multiple Choice' OR @Survey_Type = 'Paragraph Text' or @Survey_Type = 'Text'
						--begin
							select @optionstr = Question_Option from T0052_SurveyTemplate  WITH (NOLOCK)
							where SurveyQuestion_Id=@SurveyQuestion_Id and Survey_Id = @Survey_Id
														
							--IF @Survey_Type = 'Paragraph Text' or @Survey_Type = 'Text'
							--	BEGIN	
							--		insert into #Table1 (Question_Option,survey_id,SurveyQuestion_Id,Survey_Type,Answer)
							--		select @optionstr,@Survey_Id,@SurveyQuestion_Id,@Survey_Type,@Answer
							--	END
							--ELSE
								--BEGIN	
									insert into #Table1 (Question_Option,survey_id,SurveyQuestion_Id,Survey_Type)
									select CAST(DATA  AS nvarchar(1200)),@Survey_Id,@SurveyQuestion_Id,@Survey_Type from dbo.Split (@optionstr,'#')
							--	END

								--update #Table1
								--set ANSWER =a.Answer
								--from  (select EM.Answer,EM.SurveyQuestion_Id from  T0060_SurveyEmployee_Response EM
								--		INNER JOIN #Table1 TB ON EM.SurveyQuestion_Id=TB.SurveyQuestion_Id
								--	   where EM.SurveyQuestion_Id=@SurveyQuestion_Id and EM.Survey_Id=@Survey_Id)a
								--where Emp_id = @col2	

							declare cur cursor
							for 
							select Question_Option,emp_id from #Table1 where Question_Option <> ''
								open cur
									fetch next from cur into @col1,@col2
									while @@FETCH_STATUS = 0
										Begin
											-- get total count
											select @tot_cnt = COUNT(emp_id) from #FINAL_EMP
											WHERE SurveyQuestion_Id = @SurveyQuestion_Id 
											
											 --IF @Survey_Type = 'Paragraph Text' or @Survey_Type = 'Text'
												--	Begin
																											
												--	End		
											 --ELSE 
												begin
														IF @Survey_Type='CheckBoxList'
															select @res_cnt =  COUNT(emp_id) from #FINAL_EMP WHERE SurveyQuestion_Id = @SurveyQuestion_Id and CHARINDEX(@col1,Answer ) > 0
														ELSE
															select @res_cnt =  COUNT(emp_id) from #FINAL_EMP WHERE SurveyQuestion_Id = @SurveyQuestion_Id and Answer=@col1


														set @chkcnt = @chkcnt + @res_cnt

														update #Table1 
														set Res_Count = @res_cnt,
														 Response = case when @tot_cnt > 0 then (CAST((@res_cnt * 100) AS numeric(18,2)) / @tot_cnt) else @res_cnt end
														Where Question_Option = @col1  and survey_id = @Survey_Id and SurveyQuestion_Id = @SurveyQuestion_Id		
													End													
																						
											fetch next from cur into @col1,@col2
										End
								close cur
								deallocate cur																				
						--End					
					fetch next from cur1 into @SurveyQuestion_Id,@Survey_Type
				end
			CLOSE cur1
			DEALLOCATE cur1
			--SELECT 333,* FROM #Table1

			SELECT s.* ,c.cmp_logo,c.Cmp_Name,m.Survey_Title,convert(NVARCHAR(11),m.SurveyStart_Date,103)AS SurveyStart_Date,convert(NVARCHAR(11),
			m.Survey_OpenTill,103)AS Survey_OpenTill,m.Survey_Purpose,@String_Name as Filter_String,
			(SELECT sum(Res_Count)*100 FROM #Table1 WHERE Question_Option <>'' and Question_Option like '%Strongly Agree%' or Question_Option like '%/Agree%')/ (SELECT sum(Res_Count) FROM #Table1 WHERE Question_Option <>'') as OCI
			FROM T0052_SurveyTemplate s WITH (NOLOCK) LEFT JOIN 
			T0050_SurveyMaster m WITH (NOLOCK) on m.Survey_ID = s.Survey_Id LEFT JOIN
			T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id= s.Cmp_Id
			WHERE s.survey_id = @Survey_Id AND c.Cmp_Id=@Cmp_Id and Survey_Type not in('Text','Paragraph Text') 
			ORDER BY Sorting_No,SurveyQuestion_Id
			
			

			SELECT * FROM #Table1 WHERE Question_Option <>'' --and isnull(Emp_id,0)  > 0

			 

			

			

			SELECT * FROM  #Table2	
			DROP TABLE #Table1
			DROP TABLE #Table2
		END
	ELSE IF @flag=3
		BEGIN
			--added on 29/09/2017-- to bring employee data ---------------				
			INSERT INTO #Table2(Answer,survey_id,SurveyQuestion_Id,Survey_Type,Emp_id,Employee_Code,Employee_Name,survey_Question,Response_Date,Mobile_No,IMEI_NO,Survey_Title,SurveyStart_Date,Survey_OpenTill)						
			SELECT distinct A2.Data as Answer,A1.Survey_Id,A1.SurveyQuestion_Id,Survey_Type,SR.Emp_Id,'="' + EM.Alpha_Emp_Code + '"',EM.Emp_Full_Name as EmployeeName,A1.Survey_Question,
			convert(varchar(15),em.Response_Date,103),em.Mobile_No,EID.IMEI_No,SM.Survey_Title,convert(NVARCHAR(11),SM.SurveyStart_Date,103),convert(NVARCHAR(11),SM.Survey_OpenTill,103)
			FROM  T0052_SurveyTemplate A1 WITH (NOLOCK) INNER JOIN
				(
					SELECT t.Data,t1.SurveyQuestion_Id 
					FROM T0052_SurveyTemplate as t1 WITH (NOLOCK)
					CROSS APPLY [dbo].Split(Question_Option,'#') as t
					WHERE Survey_Id = @Survey_Id and isnull(Question_Option,'') <> ''
					AND t.Data<>''
				)A2 ON A1.SurveyQuestion_Id = A2.SurveyQuestion_Id
			INNER JOIN T0050_SurveyMaster SM WITH (NOLOCK) on SM.Survey_ID = A1.Survey_Id
			LEFT JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON SR.Answer like '%' + A2.Data + '%' AND
					  A1.Survey_Id = SR.Survey_Id and A1.SurveyQuestion_Id = SR.SurveyQuestion_Id
			LEFT JOIN #FINAL_EMP EM on EM.Emp_ID = SR.Emp_Id	
			LEFT JOIN(SELECT IMEI_NO,Emp_ID FROM T0095_Emp_IMEI_Details EI
					 WHERE TRAN_ID=(SELECT MAX(Tran_ID) FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID=EI.Emp_ID))EID ON EID.Emp_ID=SR.EMP_ID 
			WHERE A1.Survey_Id = @Survey_Id and (Survey_Type <> 'Title' and Survey_Type<>'Text' and Survey_Type<>'Paragraph Text') 
			UNION ALL
			SELECT distinct SR.Answer,SR.Survey_Id,SR.SurveyQuestion_Id,T.Survey_Type,SR.Emp_Id,'="' + EM.Alpha_Emp_Code + '"',EM.Emp_Full_Name as EmployeeName,T.Survey_Question,
			convert(varchar(15),em.Response_Date,103),em.Mobile_No,EID.IMEI_No,SM.Survey_Title,convert(NVARCHAR(11),SM.SurveyStart_Date,103),convert(NVARCHAR(11),SM.Survey_OpenTill,103)
			FROM T0052_SurveyTemplate T WITH (NOLOCK)
			INNER JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON T.Survey_Id = SR.Survey_Id AND SR.SurveyQuestion_Id = T.SurveyQuestion_Id
			INNER JOIN #FINAL_EMP EM ON EM.Emp_ID = SR.Emp_Id
			INNER JOIN T0050_SurveyMaster SM WITH (NOLOCK) on SM.Survey_ID = T.Survey_Id
			LEFT JOIN(SELECT IMEI_NO,Emp_ID FROM T0095_Emp_IMEI_Details EI WITH (NOLOCK)
					 WHERE TRAN_ID=(SELECT MAX(Tran_ID) FROM T0095_Emp_IMEI_Details WHERE Emp_ID=EI.Emp_ID))EID ON EID.Emp_ID=SR.EMP_ID 
			WHERE  SR.Survey_Id = @Survey_Id and (Survey_Type='Text' OR Survey_Type='Paragraph Text') order by Sorting_No
			
			--SELECT 444 ,* FROM #Table2
			ALTER TABLE #Table2 ADD Row_ID INT
			
			UPDATE	T
			SET		ROW_ID = T1.ROW_ID
			FROM	#Table2 T
					INNER JOIN  (SELECT	ROW_NUMBER() OVER(PARTITION BY survey_Question ORDER BY survey_Question,Employee_Code) AS ROW_ID, Emp_id,SurveyQuestion_Id
								 FROM	#Table2 where Employee_Code is NOT NULL) T1 ON T.Emp_id=T1.Emp_id AND T.SurveyQuestion_Id=T1.SurveyQuestion_Id
			
			
			select distinct	Row_ID AS Sr_No, Case When Row_id = 1 Then survey_Question Else '' End As survey_Question,
					Employee_Code,Employee_Name,Answer,SurveyQuestion_Id,Emp_id,survey_id, Survey_Type,Response_Date,Mobile_No,IMEI_NO,SURVEY_TITLE,SurveyStart_Date,Survey_OpenTill
			from #Table2 where Employee_Code is NOT NULL
			order by SurveyQuestion_Id,Emp_ID,Row_id,Answer					
		
			DROP TABLE #Table2
		END	
	ELSE
		BEGIN
			CREATE TABLE #SURVEY_DETAILS
			(
				 CMP_ID				INT
				,survey_id			numeric(18,0)
				,SurveyQuestion_Id	numeric(18,0)
				,Emp_id				numeric(18,0)
				,Employee_Code		varchar(50)
				,Employee_Name		varchar(100)
				,Answer				nvarchar(800)				
				,survey_Question	nVARCHAR(MAX)
				,sorting_no			INT				
				,Branch_Name VARCHAR(250)
				,Desig_Name VARCHAR(250)
				,Dept_Name VARCHAR(250)
				,Response_Date varchar(25)
				,Survey_Title nvarchar(500)		-- changed by Deepali 1July22	
			)
	
		INSERT INTO #SURVEY_DETAILS(CMP_ID,Answer,survey_id,SurveyQuestion_Id,Emp_id,Employee_Code,Employee_Name,survey_Question,sorting_no,Branch_Name,Desig_Name,Dept_Name,Response_Date,Survey_Title)						
		SELECT T.Cmp_Id,SR.Answer,SR.Survey_Id,SR.SurveyQuestion_Id,EI.Emp_Id, EI.Alpha_Emp_Code ,EI.Emp_Full_Name as EmployeeName,
		REPLACE(REPLACE(t.survey_Question,'[',''),']',''),T.Sorting_No,EI.Branch_Name,EI.Desig_Name,EI.Dept_Name,CONVERT(varchar(15),EI.Response_Date,103)+' - '+CONVERT(varchar(5),EI.Response_Date,108),SM.Survey_Title		
		FROM T0052_SurveyTemplate T	WITH (NOLOCK)	
		INNER JOIN T0050_SurveyMaster SM WITH (NOLOCK) ON SM.Survey_ID=T.Survey_Id
		LEFT JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON SR.SurveyQuestion_Id = T.SurveyQuestion_Id and  SR.Survey_Id = T.Survey_Id
		INNER JOIN #FINAL_EMP EI ON EI.Emp_ID = SR.Emp_Id 
		WHERE T.Cmp_Id=@cmp_id and  T.Survey_Id = @survey_id and sr.Emp_Id=@Emp_ID
		ORDER BY T.Sorting_No
		--LEFT JOIN V0080_EMP_MASTER_INCREMENT_GET EI EI.EMP_ID=SR.Emp_Id
		----
		SELECT DISTINCT SD.*,c.Cmp_Name,'' AS cmp_logo FROM #SURVEY_DETAILS SD
		INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id= SD.Cmp_Id	
		END
END
