
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_HRMS_Attribute_Import]
    @cmp_id    as numeric(18,0)
   ,@Initiation_date datetime
   ,@Emp_code  varchar(100)
   ,@Attribute_ID varchar(100)
   --,@Effetcive_date datetime
   ,@Attribute varchar(max)
   ,@Weightage numeric(18,2) 
  -- ,@Score numeric(18,2) 
   --,@Comments varchar(max)  
   ,@flag  char(1)
   ,@GUID Varchar(2000) = ''
   ,@Row_No  Numeric(18,0)
   ,@Manager_Score numeric(18,2) 
   ,@Manager_comments varchar(max)
   ,@filename  varchar(100)
   ,@Log_Status Int = 0 Output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @PA_ID as NUMERIC(18,0)
	declare @InitiateId as NUMERIC(18,0)=0
	declare @Emp_id Numeric(18,0)=0
	declare @EmpAtt_ID as NUMERIC(18,0)	
	declare @PoA_Weightage Numeric(18,2)	
	declare @achievement Numeric(18,2)	
	declare @max_range as numeric(18,2)
	
	if @Emp_code=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee Code is required-' +@filename,'','Enter Employee Code',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			end	
		ELSE
			BEGIN
				select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code  and Cmp_ID = @cmp_id
				if @Emp_id=0
					BEGIN
						Set @Log_Status = 1
						INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee code does not exist-' +@filename,'','Enter proper Employee Code',GetDate(),'Appraisal-Potential Attribute',@GUID)			
						RETURN	
					END
			END	
		
		if @Initiation_date=''
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Initiation Start Date is required-' +@filename,'','Enter Initiation Start Date',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			end	
		ELSE	
			BEGIN
				select @InitiateId = InitiateId  from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id = @Emp_id and SA_Startdate=@Initiation_date and Cmp_ID = @cmp_id
				if @InitiateId=0
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Employee not initiated-' +@filename,'','Enter proper Initiation Start Date',GetDate(),'Appraisal-Potential Attribute',@GUID)			
					RETURN	
				END
			END
			
		if @Attribute=''
		BEGIN
			Set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Attribute is required-' +@filename,'','Enter Attribute',GetDate(),'Appraisal-Potential Attribute',@GUID)			
			RETURN	
		end			
		
		--if @Weightage=0
		--	BEGIN				
		--		Set @Log_Status = 1
		--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage is required-' +@filename,'','Enter Weightage',GetDate(),'Appraisal-Potential Attribute',@GUID)			
		--		RETURN	
			
		--	end	
		--else if not(@Weightage>=0 and @Weightage<=100)
		if (@Weightage < 0)
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Weightage should not be less than 0' +@filename,'','Enter proper Weightage',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			end		
			
		--if @Manager_Score=0
		--	BEGIN
		--		Set @Log_Status = 1
		--		INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score is required-' +@filename,'','Enter Score',GetDate(),'Appraisal-Potential Attribute',@GUID)			
		--		RETURN	
		--	end		
		if (@Manager_Score < 0)
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score should not be less than 0' +@filename,'','Enter proper Score',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			end	
			
		--if @Score > @Weightage
		--BEGIN
		--	Set @Log_Status = 1
		--	INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score sholud not be greater than weightage',@Emp_code,'Enter Score',GetDate(),'Self Appraisal',@GUID)			
		--	RETURN	
		--end			
		
		---if @Effetcive_date <> '' and @Attribute <> ''
		if @Attribute_ID <> ''
			BEGIN
			--select RIGHT('16112510', LEN('16112510') - 6)
				select @PA_ID=PA_ID from T0040_HRMS_AttributeMaster WITH (NOLOCK) where Cmp_ID=@Cmp_Id and PA_Type='PoA' and PA_ID=cast(RIGHT(@Attribute_ID, LEN(@Attribute_ID) - 6) as NUMERIC)
			END
		ELSE
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Attribute ID not match with Master-' +@filename,'','Enter proper Attribute',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			END
		
		set @achievement=(@Weightage*@Manager_Score)
		--print @achievement
		select @max_range=MAX (range_to) from T0040_HRMS_RangeMaster WITH (NOLOCK) where Range_Type=1 and Cmp_ID=@cmp_id
		and isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))=
		(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from [T0040_HRMS_RangeMaster] WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @Initiation_date)
			--print @max_range		
		--print @max_range
		if @achievement > @max_range 
			BEGIN	
			--print 'm'		
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				VALUES (@Row_No,@Cmp_Id,@Emp_code ,'Score should not exceed ' + CAST(@max_range as varchar(10)),'','Enter proper Score',GetDate(),'Appraisal-Potential Attribute',@GUID)			
				RETURN	
			end		
	--if @flag ='I'
	if not EXISTS(select 1 from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Emp_Id=@Emp_Id and Initiation_Id=@InitiateId and PA_ID=@PA_ID and Cmp_ID=@cmp_ID)									
		BEGIN	
			select @EmpAtt_ID = isnull(max(EmpAtt_ID),0) + 1 from T0052_HRMS_AttributeFeedback WITH (NOLOCK)
				Insert into T0052_HRMS_AttributeFeedback
				(
						EmpAtt_ID
					   ,Cmp_ID
					   ,Initiation_Id
					   ,Emp_Id
					   ,PA_ID
					   ,Att_Type
					   ,Att_Score
					   ,Att_Achievement
					   ,Att_Critical
				)
				values
				(
						@EmpAtt_ID
					   ,@Cmp_ID
					   ,@InitiateId
					   ,@Emp_Id
					   ,@PA_ID
					   ,'PoA'
					   ,@Manager_Score
					   ,@achievement
					   ,@Manager_comments
				)						
		END	
	ELSE
		BEGIN
				update T0052_HRMS_AttributeFeedback
				set Att_Score=@Manager_Score,Att_Achievement=@achievement,Att_Critical=@Manager_comments
				where PA_ID=@PA_ID and Emp_Id=@Emp_Id and Initiation_Id=@InitiateId
		END
	exec Appraisal_Final_Score_Calculation @Cmp_Id,@Emp_id,@InitiateId		
END

