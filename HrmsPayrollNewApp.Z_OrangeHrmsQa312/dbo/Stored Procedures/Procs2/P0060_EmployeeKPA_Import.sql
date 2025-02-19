
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0060_EmployeeKPA_Import] 
	 @parameter	varchar(100)
	,@Effective_date Datetime
	,@Department Varchar(100) --Mukti(11022016)
	,@Cmp_Id     Numeric(18,0)
	,@KPA_Content nvarchar(1000)	--By Deepali -04-Apr-22- for unicode 
	,@KPA_Measure nvarchar(500)   --By Deepali -04-Apr-22- for unicode 
	,@KPA_Target nvarchar(1000)=''  --By Deepali -04-Apr-22- for unicode 
	,@KPA_Weightage Numeric(18,2)=0
	,@KPA_Type varchar(100) --Mukti(08022017) 
	,@Completion_Date datetime
	,@flag integer =0 --Mukti 01122015
	,@GUID Varchar(2000) = ''
	,@Row_No  Numeric(18,0)
	,@Log_Status Int = 0 Output
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	declare @Emp_KPA_Id Numeric(18,0)
	declare @Emp_id Numeric(18,0)=0
	declare @Desig_id Numeric(18,0)=0
	declare @Dept_id Numeric(18,0)=0--Mukti(11022016)
	declare @KPA_Type_Id NUMERIC(18,0)=0
	
	if @flag=0 --Mukti 01122015 for import of Employeewise
	begin
		if ISNULL(@Effective_date,'') = ''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@parameter ,'Effective Date is required','','Enter Effective Date',GetDate(),'Appraisal-Employee KPA',@GUID)			
				RETURN	
			end		
			
		if ISNULL(@parameter,'') = ''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@parameter ,'Employee Code is required','','Enter Employee Code',GetDate(),'Appraisal-Employee KPA',@GUID)			
				RETURN	
			end	
		ELSE
			BEGIN
				select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @parameter  and Cmp_ID = @cmp_id
				if @Emp_id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@parameter ,'Employee code does not exist','','Enter proper Employee Code',GetDate(),'Appraisal-Employee KPA',@GUID)			
						RETURN	
					END
			END
			
		if ISNULL(@KPA_Content,'') = ''
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@parameter ,'KPA Content is required','','Enter KPA Content',GetDate(),'Appraisal-Employee KPA',@GUID)			
			RETURN	
		end		
		
		if not(@KPA_Weightage>=0 and @KPA_Weightage<=100)
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@parameter ,'Weightage should be between 0 to 100','','Enter proper Weightage',GetDate(),'Appraisal-Employee KPA',@GUID)			
			RETURN	
		end									
				
		if ISNULL(@KPA_Type,'') <> ''			
			BEGIN
				select @KPA_Type_Id = KPA_Type_Id  from T0040_HRMS_KPAType_Master WITH (NOLOCK) where TRIM(KPA_Type) = @KPA_Type  and Cmp_ID = @cmp_id
				if @KPA_Type_Id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@parameter ,'Type does not exist','','Enter proper Type',GetDate(),'Appraisal-Employee KPA',@GUID)			
						RETURN	
					END
			END	  
		ELSE
			set @KPA_Type_Id = NULL
			
			DECLARE @TotWeightage AS NUMERIC(18,2)
			DECLARE @Weightage1 AS NUMERIC(18,2)
			
			SELECT @Weightage1 = sum(KPA_Weightage) from T0060_Appraisal_EmployeeKPA WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_Id=@cmp_id and Effective_date=@Effective_date
					SET @TotWeightage = @Weightage1+@KPA_Weightage
			print @TotWeightage
			
			if(@TotWeightage > 100)
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@parameter ,'Weightage should not be greater than 100','','Weightage should not be greater than 100',GetDate(),'Appraisal-Employee KPA',@GUID)			
					RETURN	
				END
				 
		  if @Emp_id >0
			begin
				 --added by Deepali-23-11-2022- Start
				 declare  @KPA_InitiateId	numeric(18,0)
				 set @KPA_InitiateId = 0 
				 select @KPA_InitiateId = isnull(KPA_InitiateId,0) from  T0055_Hrms_Initiate_KPASetting where Emp_Id = @Emp_Id and Cmp_Id =@Cmp_Id and KPA_StartDate = @Effective_date 
				 and KPA_EndDate=@Completion_Date
				 print @KPA_InitiateId
				 if @KPA_InitiateId = 0 
				 begin
						SELECT @KPA_InitiateId = isnull(MAX(KPA_InitiateId),0)+1 FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK)
						INSERT INTO T0055_Hrms_Initiate_KPASetting
						(
							KPA_InitiateId,Cmp_Id,Emp_Id,KPA_StartDate,KPA_EndDate  ,Initiate_Status ,Year,RM_Required ,Hod_Id ,GH_Id,Emp_ApprovedDate,Rm_ApprovedDate,HOD_ApprovedDate,GH_ApprovedDate ,emp_Comment
						   ,RM_Comment ,HOD_Comment,GH_Comment ,Review_Type,Send_to_RM,Duration_FromMonth,Duration_ToMonth,[Period]
						)VALUES
						(
							@KPA_InitiateId,@Cmp_Id,@Emp_Id,@Effective_date,@Completion_Date,4,year(@Effective_date),@Emp_Id,@Emp_Id ,@Emp_Id,@Completion_Date,@Completion_Date ,@Completion_Date,@Completion_Date,''
						   ,'','','','',1,month(@Effective_date),month(@Completion_Date),''
						)
				end 
				--added by Deepali-23-11-2022- End

				 select @Emp_KPA_Id = Isnull(max(Emp_KPA_Id),0) + 1	From T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
						
				 INSERT INTO T0060_Appraisal_EmployeeKPA
				 (Emp_KPA_Id,Cmp_Id,Emp_Id,KPA_Content,KPA_Target,KPA_Weightage,Effective_date,[status],KPA_Type_ID,KPA_Performace_Measure,Completion_Date,Is_Active,KPA_InitiateId,Approval_Level)    
				 VALUES(@Emp_KPA_Id,@Cmp_Id,@Emp_Id,@KPA_Content,@KPA_Target,@KPA_Weightage,@Effective_date,1,@KPA_Type_Id,@KPA_Measure,@Completion_Date,1,@KPA_InitiateId,'EMP') 
				end
		end
		-- Added By Mukti 01122015(start)
	else  --for import of Designationwise
		begin
			if ISNULL(@Effective_date,'') = ''
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,'','Effective Date is required','','Enter Effective Date',GetDate(),'Appraisal-Designation KPA',@GUID)			
					RETURN	
				end		
			
			if ISNULL(@parameter,'') = ''
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,'','Designation is required','','Enter Designation',GetDate(),'Appraisal-Designation KPA',@GUID)			
					RETURN	
				end	
			ELSE
				BEGIN
					select @Desig_id = Desig_ID  from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_Name = @parameter  and Cmp_ID = @cmp_id
					if @Desig_id=0
						BEGIN
							Set @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
							VALUES (@Row_No,@Cmp_Id,'','Designation does not exist','','Enter proper Designation',GetDate(),'Appraisal-Designation KPA',@GUID)			
							RETURN	
						END
				END	
				
			if (ISNULL(@Department,'') <> '')
				BEGIN
					if exists(select  Dept_id  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Dept_Name = @Department  and Cmp_ID = @cmp_id)
						BEGIN
							select @Dept_id = Dept_id  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Dept_Name = @Department  and Cmp_ID = @cmp_id
						END
					ELSE
						BEGIN
							set @Dept_id = 0
							Set @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
							VALUES (@Row_No,@Cmp_Id,'','Department does not exist','','Enter proper Department',GetDate(),'Appraisal-Designation KPA',@GUID)			
							RETURN
						END
				END
			ELSE
				BEGIN
					set @Dept_id = 0
				END
			
		if ISNULL(@KPA_Content,'') = ''
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,'','KPA Content is required','','Enter KPA Content',GetDate(),'Appraisal-Designation KPA',@GUID)			
			RETURN	
		end		
		
		if not(@KPA_Weightage>=0 and @KPA_Weightage<=100)
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,'','Weightage should be between 0 to 100','','Enter proper Weightage',GetDate(),'Appraisal-Designation KPA',@GUID)			
			RETURN	
		end				
		
		if ISNULL(@KPA_Type,'') <> ''			
			BEGIN
				select @KPA_Type_Id = KPA_Type_Id  from T0040_HRMS_KPAType_Master WITH (NOLOCK) where KPA_Type = @KPA_Type  and Cmp_ID = @cmp_id
				if @KPA_Type_Id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@parameter ,'Type does not exist','','Enter proper Type',GetDate(),'Appraisal-Employee KPA',@GUID)			
						RETURN	
					END
			END	  
				
		  if @Desig_id >0
			begin
				select @Emp_KPA_Id = Isnull(max(KPA_Id),0) + 1 	From T0051_KPA_Master WITH (NOLOCK)
				Insert into T0051_KPA_Master
				(KPA_id,Cmp_Id,Desig_Id,KPA_Content,KPA_Target,KPA_Weightage,Dept_id,Effective_Date,KPA_Type_ID,KPA_Performace_Measure,Completion_Date)
				Values(@Emp_KPA_Id,@Cmp_Id,@Desig_id,@KPA_Content,@KPA_Target,@KPA_Weightage,@Dept_id,@Effective_date,@KPA_Type_Id,@KPA_Measure,@Completion_Date) 
			end
		end
		-- Added By Mukti 01122015(end)
RETURN



