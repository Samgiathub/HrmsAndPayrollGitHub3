

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0060_Datewise_EmployeeKPA_Import] 
	 @Emp_code	varchar(100)
	,@Initiation_date Datetime	
	,@Cmp_Id     Numeric(18,0)
	,@ContentKPA_ID Numeric(18,0)
	,@KPA_Content varchar(max)
	,@KPA_Target varchar(1000)=''
	,@KPA_Weightage Numeric(18,2)
	,@Employee_Score Numeric(18,2)
	,@justification varchar(max)=''	
	,@GUID Varchar(2000) = ''
	,@Row_No  Numeric(18,0)
	,@Log_Status Int = 0 Output
	,@flag	Int
	,@RM_Score Numeric(18,2)
	,@RM_Comments varchar(max)=''	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
	declare @KPA_ID Numeric(18,0)
	declare @InitiateId Numeric(18,0)=0
	declare @Emp_id Numeric(18,0)=0
	declare @Desig_id Numeric(18,0)
	declare @Dept_id Numeric(18,0)--Mukti(11022016)
	declare @EKPA_Weightage Numeric(18,2)=0
	declare @tot_empweightage Numeric(18,2)=0
	declare @Direct_send as Int
						
					
	begin	
		if @Emp_code=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Code is required',@Emp_code,'Enter Employee Code',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
				RETURN	
			end	
		ELSE
			BEGIN
				select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code  and Cmp_ID = @cmp_id
				if @Emp_id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee code does not exist',@Emp_code,'Enter proper Employee Code',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
						RETURN	
					END
			END	
		
		if @Initiation_date=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Initiation Start Date is required',@Emp_code,'Enter Initiation Start Date',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
				RETURN	
			end	
		ELSE	
			BEGIN
				select @InitiateId = InitiateId  from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @Emp_id and SA_Startdate=@Initiation_date and Cmp_ID = @cmp_id
				if @InitiateId=0
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee not initiated.',@Emp_code,'Enter proper Initiation Start Date',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
					RETURN	
				END
			END
			--print @InitiateId
		if @KPA_Content=''
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'KPA Content is required','','Enter KPA Content',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end		
		
		if @KPA_Weightage=0
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage is required','','Enter Weightage',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end		
		else if not(@KPA_Weightage>=0 and @KPA_Weightage<=100)
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage should be between 0 to 100','','Enter proper Weightage',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end		
		
		if (@Employee_Score=0 and @RM_Score=0)  --if @Employee_Score=0 
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score is required','','Enter Employee/Manager Score',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end		
		--else if not(@Employee_Score>=0 and @Employee_Score<=100)
		--BEGIN
		--	Set @Log_Status = 1
		--	INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--	VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Score should be between 0 to 100',@Emp_code,'Enter proper Employee Score',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
		--	RETURN	
		--end	
		if @Employee_Score > @KPA_Weightage
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Score sholud not be greater than weightage','','Enter Employee Score',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end	
		
		if @RM_Score > @KPA_Weightage		
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'RM Score sholud not be greater than weightage','','Enter RM Score',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
			RETURN	
		end					
		
		  if (@flag=0)  --to insert record and flag=1 to update rm_score from reporting manager
			begin
				select @EKPA_Weightage=ISNULL(EKPA_Weightage,0) from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where Cmp_Id=@Cmp_Id and emp_id=@Emp_id 
				and isnull(EKPA_RestrictWeightage,0)=1 and Effective_Date =(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) 
				from T0060_Appraisal_EmpWeightage WITH (NOLOCK) where emp_id=@Emp_id)
				--PRINT @Emp_id
				--PRINT @InitiateId
			  select @tot_empweightage=sum(KPA_Weightage) from T0052_HRMS_KPA WITH (NOLOCK) where Emp_Id=@Emp_id and InitiateId=@InitiateId GROUP by Emp_Id
			  set @tot_empweightage=@tot_empweightage + @KPA_Weightage
			  --PRINT	@EKPA_Weightage
			  --PRINT	@tot_empweightage
			  if ((@EKPA_Weightage >0)AND(ISNULL(@tot_empweightage,0) > @EKPA_Weightage))
			  BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Total Weighatge should be equal to ' + cast(@EKPA_Weightage as VARCHAR(10)) ,'','Weighatge exceed',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
				RETURN			
			  END
			  --print 'k'
					select @KPA_ID = isnull(max(KPA_ID),0) + 1 from T0052_HRMS_KPA WITH (NOLOCK)
					Insert into T0052_HRMS_KPA
						(
							 KPA_ID
							,Cmp_ID
							,InitiateId
							,Emp_Id
							,KPA_Content
							,KPA_Achievement
							,KPA_Critical
							,KPA_Target			
							,KPA_Weightage		
							,KPA_AchievementEmp   
							,KPA_AchievementRM	
							,RM_Comments
						)
						values
						(
							 @KPA_ID
							,@Cmp_ID
							,@InitiateId
							,@Emp_Id
							,@KPA_Content
							,@RM_Score
							,@justification
							,@KPA_Target		
							,@KPA_Weightage		
							,@Employee_Score   
							,@RM_Score
							,@RM_Comments
						) 
				if @RM_Score >0
					BEGIN
						update T0050_HRMS_InitiateAppraisal 
						set SA_Status=1,SA_ApprovedDate=GETDATE(),SA_SubmissionDate=GETDATE()
						where InitiateId=@InitiateId and Cmp_Id=@Cmp_Id	and Emp_Id=@Emp_Id
					END
					
				exec Appraisal_Final_Score_Calculation @Cmp_Id,@Emp_id,@InitiateId
			end
		--ELSE
		--	BEGIN
		--		if @RM_Score > @KPA_Weightage
		--			BEGIN
		--				Set @Log_Status = 1
		--				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_code ,'RM Score sholud not be greater than weightage',@Emp_code,'Enter RM Score',GetDate(),'Appraisal-Employee KPA Datewise',@GUID)			
		--				RETURN	
		--			end					
				
		--			select @KPA_ID=KPA_ID from T0052_HRMS_KPA where Emp_Id=@Emp_id and InitiateId=@InitiateId and cmp_id=@Cmp_Id and KPA_ID=cast(RIGHT(@ContentKPA_ID, LEN(@ContentKPA_ID) - 6) as NUMERIC) and Cmp_ID=@Cmp_ID
					
		--			UPDATE T0052_HRMS_KPA
		--			set KPA_AchievementRM=@RM_Score,RM_comments=@RM_Comments,KPA_Achievement=@RM_Score
		--			where KPA_ID=@KPA_ID and InitiateId=@InitiateId and Emp_Id=@Emp_id
					
		--			exec Appraisal_Final_Score_Calculation @Cmp_Id,@Emp_id,@InitiateId
		--	END
		end	
RETURN


