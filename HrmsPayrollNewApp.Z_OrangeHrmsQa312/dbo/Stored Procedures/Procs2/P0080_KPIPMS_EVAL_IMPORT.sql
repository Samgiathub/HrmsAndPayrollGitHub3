

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0080_KPIPMS_EVAL_IMPORT]
	@Cmp_ID						numeric(18,0)
	,@Emp_code					varchar(30)
	,@Type						varchar(30)
	,@KPIPMS_Name				varchar(50)
	,@KPIPMS_FinancialYr		varchar(30)
	,@Status					varchar(50)
	,@KPIPMS_SupEarlyComment	varchar(500)=null
	,@Final_Training			varchar(max) =null  
	,@Final_Training_Emp        varchar(max) =null  
	,@Comment					varchar(500)=null
	,@KPIPMS_AdditionalAchivement varchar(1000) = null      
	,@User_Id					numeric(18,0) = 0
	,@IP_Address				varchar(30)= '' 
	,@Row_No					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	DECLARE  @KPIPMS_ID	numeric(18,0)
	DECLARE	 @Emp_ID	numeric(18,0)
	DECLARE @year  varchar(15)
	DECLARE @KPIPMS_Status	numeric(18,0)--=8
	DECLARE @KPIPMS_Type numeric(18,0)--=0
	
	SET @KPIPMS_Status = 8
	SET @KPIPMS_Type =0
	
	DECLARE @temp_data table
		(	
			 Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPIPMS_ID  varchar(50)
			,error_messge varchar(500)
		)
	
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,@Emp_code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end		
			
		if @Type='Final'
			begin
				SET @KPIPMS_Type=2
				set	@Final_Training=@Final_Training
				set @Final_Training_Emp=@Final_Training_Emp
			end	
		else if @Type='Interim'
			begin
				SET @KPIPMS_Type=1
				set	@Final_Training=null
				set @Final_Training_Emp=null
			end						
	
		if 	@Final_Training <> ''
			begin
			--	set @ertra1= LEFT(@Final_Training, charindex('#', @Final_Training) - 1)
				--set @ertra1= CHARINDEX('error',@Final_Training)
				if CHARINDEX('error',@Final_Training)>0
				begin
					insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Training Name not properly inserted')
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (@Row_No,@Cmp_Id,@Emp_Code,'Training Name not properly inserted',0,'Enter Proper Training Name',GetDate(),'KPI Review')						
					select * from  @temp_data
					return
				end	
			end			
			
		if 	@Final_Training_Emp <> ''
			begin
			if CHARINDEX('error',@Final_Training_Emp)>0
				begin
					insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Training Name not properly inserted')
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (@Row_No,@Cmp_Id,@Emp_Code,'Training Name not properly inserted',0,'Enter Proper Training Name',GetDate(),'KPI Review')						
					select * from  @temp_data
					return
				end	
			end			
				
		if @KPIPMS_FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@KPIPMS_FinancialYr, charindex('-', @KPIPMS_FinancialYr) - 1)
			end		
			
			
		if @Status ='Draft'
			begin
				SET	@KPIPMS_Status=0
			end
		ELSE IF @Status='Send for Employee review'
			begin
				SET	@KPIPMS_Status=1
			end
		ELSE IF @Status='Reviewed by Employee'
			begin
				SET	@KPIPMS_Status=2
			end
		ELSE IF @Status='Approved by Employee'
			begin
				SET	@KPIPMS_Status=3
			end	
		ELSE IF @Status='Approved by Line Manager'
			begin
				SET	@KPIPMS_Status=4
			end		
		ELSE IF @Status='Send back for Review'
			begin
				SET	@KPIPMS_Status=5
			end		
		ELSE IF @Status='Reject'
			begin
				SET	@KPIPMS_Status=6
			end		
		ELSE IF @Status='Approve'
			begin
				SET	@KPIPMS_Status=7
			end		
			
		IF @KPIPMS_Status=8
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Enter Proper Status')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Status',0,'Enter Proper Status',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
			
		if @KPIPMS_Type=0
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Enter Proper Appraisal Type')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Type',0,'Enter Proper Appraisal Type',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
							
		if @KPIPMS_Name=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Enter Proper Appraisal Name')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Name',0,'Enter Proper Appraisal Name',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
			
			if @KPIPMS_Type=1
				begin
					if exists(select 1 from T0080_KPIPMS_EVAL WITH (NOLOCK) where emp_id=@emp_id and KPIPMS_Type=@KPIPMS_Type and cmp_id=@cmp_id and KPIPMS_Name=@KPIPMS_Name and KPIPMS_FinancialYr=@year)
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Already exist')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Already exist',0,'Already exist',GetDate(),'KPI Review')						
						select * from  @temp_data
						return
					end
				end
				
			if @KPIPMS_Type=2
				begin
				 if exists(select 1 from T0080_KPIPMS_EVAL WITH (NOLOCK) where emp_id=@emp_id and KPIPMS_Type=@KPIPMS_Type and cmp_id=@cmp_id and KPIPMS_FinancialYr=@year)
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Already exist')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Already exist',0,'Already exist',GetDate(),'KPI Review')						
						select * from  @temp_data
						return
					end
				end
		
					select @KPIPMS_ID = isnull(max(KPIPMS_ID),0) + 1 from T0080_KPIPMS_EVAL WITH (NOLOCK)
					Insert Into T0080_KPIPMS_EVAL
				   (
					 KPIPMS_ID					
					,Cmp_ID					
					,Emp_ID					
					,KPIPMS_Type				
					,KPIPMS_Name				
					,KPIPMS_FinancialYr		
					,KPIPMS_Status				
					,KPIPMS_FinalRating		
					,KPIPMS_EmProcessFair		
					,KPIPMS_EmpAgree			
					,KPIPMS_EmpComments		
					,KPIPMS_ProcessFairSup		
					,KPIPMS_SupAgree			
					,KPIPMS_SupComments	
					,KPIPMS_EmpEarlyComment	
					,KPIPMS_SupEarlyComment	
					,KPIPMS_EarlyComment
					,KPIMPS_StartedOn	
					,KPIMPS_EmpAppOn	
					,KPIMPS_SupAppOn
					,KPIPMS_FinalApproved
					,Final_Score					
					,SignOff_EmpDate				
					,SignOff_SupDate				
					,Final_Close					
					,Final_ClosedOn				
					,Final_ClosedBy				
					,Final_ClosingComment	
					,Final_Training		
					,Final_Training_Emp   
					,KPIPMS_ManagerScore	
					,KPIPMS_EmpScore		
					,KPIPMS_AdditionalAchivement	
				)
				values
				(
					 @KPIPMS_ID					
					,@Cmp_ID					
					,@Emp_ID					
					,@KPIPMS_Type				
					,@KPIPMS_Name				
					,@year		
					,@KPIPMS_Status				
					,NULL		
					,NULL		
					,NULL			
					,''		
					,''		
					,NULL			
					,NULL
					,''	
					,@KPIPMS_SupEarlyComment
					,@Comment
					,GETDATE()
					,null
					,null 
					,null
					,NULL					
					,null 	
					,null		
					,NULL					
					,null 		
					,NULL				
					,''
					,@Final_Training	
					,@Final_Training_Emp  
					,NULL	
					,NULL
					,@KPIPMS_AdditionalAchivement	
				)
	
	--else
	--	begin
	--		insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ID,error_messge) values(0,'',0,'Already exist')
	--		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Already exist',0,'Already exist',GetDate(),'KPI Review')						
	--		select * from  @temp_data
	--		return
	--	end	
		
End
		--else
		--	begin 
		--		select @KPIPMS_ID=KPIPMS_ID from T0080_KPIPMS_EVAL where Emp_ID=@Emp_ID and KPIPMS_Type=@KPIPMS_Type and KPIPMS_Name=@KPIPMS_Name and KPIPMS_FinancialYr=@KPIPMS_FinancialYr
		--		select @KPIPMS_ID
		--	ENd
		
	


