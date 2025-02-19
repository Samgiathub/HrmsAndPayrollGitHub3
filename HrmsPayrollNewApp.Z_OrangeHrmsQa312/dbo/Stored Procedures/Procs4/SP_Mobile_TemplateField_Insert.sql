-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 18/07/2023
-- Description:	Insert the Template Field Answer Data API
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_TemplateField_Insert] 
	@Emp_ID NUMERIC(18,0),
	@Cmp_ID NUMERIC(18,0),
	@T_ID NUMERIC(18,0),
	@Template_Details XML,
	@Login_ID NUMERIC(18,0),
	--@IMEINo VARCHAR(100),
	@Type char(1),
	--@T_Field_Type nvarchar(100),
	@Result varchar(100) OUTPUT
AS
BEGIN
	IF @Type = 'I' -- For Template Insert
	BEGIN
	
		--DECLARE @TRAN_TYPE AS VARCHAR(2)
		--SET @TRAN_TYPE = 'I'
		--IF EXISTS(SELECT 1 FROM T0060_SurveyEmployee_Response WHERE CMP_ID = @Cmp_ID AND Survey_Id = @Survey_ID AND Emp_Id = @Emp_ID)
		--	BEGIN
		--		SET @TRAN_TYPE = 'U'
		--	END
		
		DECLARE @ETR_ID NUMERIC(18,0)
		DECLARE @F_ID NUMERIC(18,0)
		DECLARE @Answer nVARCHAR(MAX)
		DECLARE @Flag int
		--Declare @Field_Type nvarchar(100)
		DECLARE @Status AS TINYINT
		
		SET @STATUS = 0
		SET @ETR_ID = 0		
		DECLARE @CURRENTDATETIME DATETIME
		SET @CURRENTDATETIME  = GETDATE()

		SET @Flag = (select top 1 Response_Flag from  T0100_Employee_Template_Response where Cmp_Id=@Cmp_ID and T_Id = @T_ID and Emp_Id = @Emp_ID
					order by ETR_Id desc)
		
		if @Flag is null or @Flag = 0
		begin
			set @Flag = 1	
		end
		else
		begin
			Set @Flag = @Flag + 1
		end
		
		--Select @Flag
		--Return
		
		SELECT --Table1.value('(SurveyEmp_ID/text())[1]','numeric(18,0)') AS SurveyEmpID,
		Table1.value('(F_ID/text())[1]','numeric(18,0)') AS F_ID,
		--Table1.value('(Field_Type/text())[1]','nvarchar(100)') AS Field_Type,
		Table1.value('(Answer/text())[1]','nvarchar(MAX)') AS Answer,
		Table1.value('(ETR_ID/text())[1]','numeric(18,0)') AS ETR_ID
		--,Table1.value('(Flag/text())[1]','int') AS Flag
		INTO #Template FROM @Template_Details.nodes('/NewDataSet/Table1') as Temp(Table1)

		DECLARE @ANS AS nVARCHAR(MAX)	
		--DECLARE @Flg as int
		SET @ANS = ''		
		--Declare @F_Type as nvarchar(100)
		--SET @F_Type = ''

		--SELECT SURVEYQUESTIONID,CAST(ANSWER AS NVARCHAR(MAX)),SURVEYEMP_ID FROM #SURVEY
		--RETURN

		--SELECT F_ID,Field_Type,Answer,ETR_ID FROM #Template
		--return

		--Select * from #Template
		--return


		DECLARE TEMPLATE_CURSOR CURSOR FAST_FORWARD FOR
		SELECT F_ID,Answer,ETR_ID FROM #Template
		--SELECT F_ID,Field_Type,Answer,ETR_ID FROM #Template
		OPEN TEMPLATE_CURSOR
		FETCH NEXT FROM TEMPLATE_CURSOR INTO @F_ID,@Answer,@ETR_ID
		--FETCH NEXT FROM TEMPLATE_CURSOR INTO @F_ID,@Field_Type,@Answer,@ETR_ID
		WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					SET @Answer = REPLACE(@Answer, '~', '#')
					SET @ANS = @Answer
					--SET @Flg = @Flag

					--SET @F_Type = @Field_Type 

					--if @ANS <> ''
					--Begin
					--	IF Right(@ANS,1) = '#'
					--	  Begin
					--		Set @ANS = LEFT(@ANS, LEN(@ANS) - 1)
					--	  End
					--End

					--select @ANS, @Answer
					--IF EXISTS(SELECT * FROM T0100_Employee_Template_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND T_Id = @T_ID AND F_Id = @F_ID and Cmp_Id = @Cmp_ID)
					--BEGIN
						EXEC P0100_Employee_Template_Response @ETR_ID OUTPUT,@Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@T_Id = @T_ID,
						@F_Id = @F_ID,@Answer = @ANS ,@tran_type = @Type,@User_Id = @Login_ID,@Response_Flag = @Flag
					--END
					--else
					--begin
						SET @Status = 0
					--end

					FETCH NEXT FROM TEMPLATE_CURSOR INTO @F_ID,@Answer,@ETR_ID
				END TRY
				BEGIN CATCH
					SET @Status = 1
				END CATCH
			END
		CLOSE TEMPLATE_CURSOR
		DEALLOCATE TEMPLATE_CURSOR
		
		--Select @Flag
		--return
		
		IF @Status = 0
			BEGIN
				SET @Result = 'Record Insert Successfully#True#'	--T_ID:' + @T_ID + '#'
				SELECT @Result
			END
		ELSE
			BEGIN
				SET @Result = 'Already Reference Exists #False#'
				SELECT @Result
			END
	END
END
