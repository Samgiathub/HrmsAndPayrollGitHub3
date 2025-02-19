



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Survey]
	@Emp_ID NUMERIC(18,0),
	@Cmp_ID NUMERIC(18,0),
	@Survey_ID NUMERIC(18,0),
	@Survey_Details XML,
	@Login_ID NUMERIC(18,0),
	@IMEINo VARCHAR(100),
	@Type char(1),
	@Result varchar(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Type = 'B'  -- For Bind Survey List
	BEGIN
	
		SELECT SM.Survey_ID,SM.Survey_Title,COUNT(DISTINCT SE.Emp_ID) AS 'Survey_Count',SUM(DISTINCT(CASE WHEN SE.Emp_Id = @Emp_ID THEN 1 ELSE 0 END)) AS 'My_Survey',
		SM.SurveyStart_Date,SM.SurveyEnd_Date,SM.Survey_Purpose,SM.Survey_Instruction,SM.Survey_OpenTill,SM.Start_Time,SM.End_Time
		FROM T0050_SurveyMaster SM WITH (NOLOCK) 
		LEFT JOIN T0060_SurveyEmployee_Response SE WITH (NOLOCK) ON SM.Survey_ID = SE.Survey_Id
		WHERE SM.Cmp_ID = @Cmp_ID AND GETDATE() >= SurveyStart_Date AND CAST(GETDATE() AS VARCHAR(12)) <= Survey_OpenTill 
		AND (Survey_EmpId LIKE '%'+ CAST(@Emp_ID AS varchar(50)) +'%' OR Survey_EmpId IS NULL)
		GROUP BY SM.Survey_ID,SM.Survey_Title,SM.SurveyStart_Date,SM.SurveyEnd_Date,SM.Survey_Purpose,SM.Survey_Instruction,SM.Survey_OpenTill,SM.Start_Time,SM.End_Time
		
	END
ELSE IF @Type = 'Q' -- For Bind Survey Question Answer Details List
	BEGIN
		
		SELECT ST.Survey_Id,isnull(SR.SurveyQuestion_Id,isnull(ST.SurveyQuestion_Id,0)) as 'SurveyQuestion_Id',ISNULL(SR.SurveyEmp_ID,0) as 'SurveyEmp_ID',
		ST.Cmp_Id,SR.Emp_Id,ST.Survey_Type,ST.Survey_Question,ST.Question_Option,SR.Answer,
		CONVERT(VARCHAR(50),SR.Response_Date,103) AS 'Response_Date',ST.Sorting_No,'' AS 'Main_Title',ST.SubQuestion,ST.Is_Mandatory
		FROM T0052_SurveyTemplate ST WITH (NOLOCK)
		LEFT JOIN T0060_SurveyEmployee_Response SR WITH (NOLOCK) ON ST.Survey_Id = SR.Survey_Id AND ST.SurveyQuestion_Id = SR.SurveyQuestion_Id AND SR.Emp_Id = @Emp_ID
		WHERE ST.Survey_Id = @Survey_ID AND ST.Cmp_Id = @Cmp_ID --AND SR.SurveyEmp_Id = @Emp_ID
		ORDER BY Sorting_No
			
		
		--create table #tempTable
		--(
		--	 Survey_Id				numeric(18,0)	
		--	,SurveyQuestion_Id		numeric(18,0)
		--	,SurveyEmp_Id			numeric(18,0)
		--	,Cmp_Id					numeric(18,0)
		--	,Emp_Id					numeric(18,0)
		--	,Survey_Type			varchar(50)	
		--	,Survey_Question		varchar(500)
		--	,Question_Option		varchar(500)
		--	,Answer					varchar(max)
		--	,Response_Date			datetime
		--	,Sorting_No				int	
		--)
		
		--declare @col1 numeric(18,0)
		--insert into #tempTable
		--(
		--	Survey_Id,SurveyQuestion_Id,Cmp_Id,Survey_Type,Survey_Question,Question_Option,Sorting_No
		--)
		--(	
		--	Select Survey_ID,SurveyQuestion_Id,Cmp_Id,Survey_Type,Survey_Question,Question_Option,Sorting_No
		--	from T0052_SurveyTemplate where Cmp_ID=@Cmp_Id and Survey_ID=@Survey_Id
		--)
		
		--declare cur cursor
		--for 
		--   select SurveyQuestion_Id from #tempTable
		--	open cur
		--		fetch next from cur into @col1
		--		while @@FETCH_STATUS = 0
		--		   begin
					
		--				update #tempTable
		--				set SurveyEmp_Id = S.SurveyEmp_Id ,Emp_Id=s.Emp_Id,Answer=s.Answer,Response_Date=s.Response_Date
		--				FROM	(	
		--							Select SurveyEmp_Id,Emp_Id,Answer,Response_Date 
		--							from T0060_SurveyEmployee_Response 
		--							where Emp_Id=@Emp_Id and Survey_Id=@Survey_Id and SurveyQuestion_Id = @col1
		--						) S 
		--				where Survey_Id = @Survey_Id and SurveyQuestion_Id = @col1
		--				fetch next from cur into @col1
		--		   End
		--   close cur
		--   deallocate cur
		   
		-- --

		
		--select Survey_Id,SurveyQuestion_Id,SurveyEmp_Id,Cmp_Id,Emp_Id,Survey_Type,Survey_Question,Question_Option,isnull(Answer,'') as Answer,
		--CONVERT(VARCHAR(50),Response_Date,103) AS 'Response_Date',Sorting_No,'' AS 'Main_Title'
		--from #tempTable order by Sorting_No
		--drop table #tempTable
		
		
		
	END
ELSE IF @Type = 'I' -- For Survey Insert
	BEGIN
	
		--DECLARE @TRAN_TYPE AS VARCHAR(2)
		--SET @TRAN_TYPE = 'I'
		--IF EXISTS(SELECT 1 FROM T0060_SurveyEmployee_Response WHERE CMP_ID = @Cmp_ID AND Survey_Id = @Survey_ID AND Emp_Id = @Emp_ID)
		--	BEGIN
		--		SET @TRAN_TYPE = 'U'
		--	END
		
		DECLARE @SurveyEmp_ID NUMERIC(18,0)
		DECLARE @SurveyQuestion_ID NUMERIC(18,0)
		DECLARE @Answer nVARCHAR(MAX)
		DECLARE @Status AS TINYINT
		
		SET @STATUS = 0
		SET @SurveyEmp_ID = 0
		DECLARE @CURRENTDATETIME DATETIME
		SET @CURRENTDATETIME  = GETDATE()
		
		SELECT --Table1.value('(SurveyEmp_ID/text())[1]','numeric(18,0)') AS SurveyEmpID,
		Table1.value('(SurveyQuestion_ID/text())[1]','numeric(18,0)') AS SurveyQuestionID,
		Table1.value('(Answer/text())[1]','nvarchar(MAX)') AS Answer,
		Table1.value('(SurveyEmp_ID/text())[1]','numeric(18,0)') AS SurveyEmp_ID
		INTO #Survey FROM @Survey_Details.nodes('/NewDataSet/Table1') as Temp(Table1)

		DECLARE @ANS AS nVARCHAR(MAX)
		SET @ANS = ''
		
		--SELECT SURVEYQUESTIONID,CAST(ANSWER AS NVARCHAR(MAX)),SURVEYEMP_ID FROM #SURVEY
		--RETURN

		DECLARE SURVEY_CURSOR CURSOR FAST_FORWARD FOR
		SELECT SurveyQuestionID,Answer,SurveyEmp_ID FROM #Survey
		OPEN SURVEY_CURSOR
		FETCH NEXT FROM SURVEY_CURSOR INTO @SurveyQuestion_ID,@Answer,@SurveyEmp_ID
		WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					--SET @ANS = REPLACE(@Answer, '~~', '#')
					SET @ANS = @Answer
					--select @ANS, @Answer
					IF NOT EXISTS(SELECT * FROM T0060_SurveyEmployee_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Survey_ID = @Survey_ID AND SurveyQuestion_ID = @SurveyQuestion_ID)
					BEGIN
							EXEC P0060_SurveyEmployee_Response @SurveyEmp_ID OUTPUT,@Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Survey_Id = @Survey_ID,
							@SurveyQuestion_Id = @SurveyQuestion_ID,@Answer = @ANS ,@Response_Date = @CurrentDatetime ,@tran_type = @Type,@User_Id = @Login_ID,
							@IP_Address = @IMEINo
							
					END

					FETCH NEXT FROM SURVEY_CURSOR INTO @SurveyQuestion_ID,@Answer,@SurveyEmp_ID
				END TRY
				BEGIN CATCH
					SET @Status = 1
				END CATCH
			END
		CLOSE SURVEY_CURSOR
		DEALLOCATE SURVEY_CURSOR
		
		
		IF @Status = 0
			BEGIN
				SET @Result = 'Record Insert Successfully#True#'
				SELECT @Result
			END
		ELSE
			BEGIN
				SET @Result = 'Something Went Wrong #False#'
				SELECT @Result
			END
	END

