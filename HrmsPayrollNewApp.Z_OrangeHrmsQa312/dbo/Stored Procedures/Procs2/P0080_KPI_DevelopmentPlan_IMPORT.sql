
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_KPI_DevelopmentPlan_IMPORT]
	 ---details of main table
	--   @KPIPMS_ID				numeric(18,0) 	output
	   @Cmp_Id					numeric(18,0)
	  ,@Emp_Code				varchar(50)
	  ,@KPIPMS_Type				varchar(50)
	  ,@KPIPMS_Name				varchar(50)
	  ,@KPIPMS_FinancialYr		varchar(50)
	--  ,@KPIPMS_Status			int=null
	 -- ,@KPIPMS_AdditionalAchievement varchar(500) 
	  ---details of KPI Development Plan
	--  ,@KPI_DevelopmentID	numeric(18,0) 
      ,@DevelopmentAreas	varchar(200)
      ,@ImprovementAction	varchar(200)
      ,@Timeline			varchar(200)
      ,@Status				varchar(200)
	  ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= '' 
	  ,@Row_No numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @KPI_DevelopmentID	numeric(18,0) 
	declare @KPIPMS_ID			numeric(18,0)
	declare @Emp_Id				numeric(18,0)
	declare @year  varchar(15)
	declare @Type numeric(18,0)
	set @Type = 0 
	
	declare @temp_data table
		(	
			 Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPI_DevelopmentID  varchar(50)
			,error_messge varchar(500)
		)
		
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(0,@Emp_Code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
		end	
		
		if @KPIPMS_FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(@Emp_Id,@Emp_Code,0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@KPIPMS_FinancialYr, charindex('-', @KPIPMS_FinancialYr) - 1)
			end		
			
		if @KPIPMS_Name=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(0,'',0,'Enter Proper Appraisal Name')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Name',0,'Enter Proper Appraisal Name',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end	
		else if exists(select KPIPMS_ID from  T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@KPIPMS_Name) and KPIPMS_FinancialYr=@year and cmp_id=@cmp_id)
			begin
				select @KPIPMS_ID=KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@KPIPMS_Name) and KPIPMS_FinancialYr=@year  and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(0,@Emp_code,0,'Appraisal Name does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Appraisal Name does not Exist in System',0,'Enter Proper Appraisal Name',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end		
									
		if @KPIPMS_Type='Final'
			begin
				SET @Type=2
			end	
		else if @KPIPMS_Type='Interim'
			begin
				SET @Type=1
			end			
			
		if @Type=0
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_DevelopmentID,error_messge) values(0,'',0,'Enter Proper Appraisal Type')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Type',0,'Enter Proper Appraisal Type',GetDate(),'KPI Review')						
				select * from  @temp_data
				return
			end		
			
			select @KPI_DevelopmentID = isnull(max(KPI_DevelopmentID),0) + 1 from T0080_KPI_DevelopmentPlan WITH (NOLOCK)
			Insert Into T0080_KPI_DevelopmentPlan
			(
				   KPI_DevelopmentID
				  ,Cmp_Id	
				  ,Emp_ID	
				  ,KPIPMS_ID
				  ,Strengths				
				  ,DevelopmentAreas		
				  ,ImprovementAction		
				  ,Timeline				
				  ,[Status]					
			)
			Values
			(
				   @KPI_DevelopmentID
				  ,@Cmp_Id		
				  ,@Emp_ID	
				  ,@KPIPMS_ID			
				  ,''			
				  ,@DevelopmentAreas	
				  ,@ImprovementAction	
				  ,@Timeline			
				  ,@Status				
			)
END
