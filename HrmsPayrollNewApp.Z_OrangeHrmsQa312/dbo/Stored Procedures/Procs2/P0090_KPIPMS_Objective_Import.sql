

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_KPIPMS_Objective_Import]
		@Cmp_Id			numeric(18,0)
		,@FinancialYr varchar(30)
		,@Emp_code varchar(30)
		,@Appraisal_Type varchar(30)
		,@Appraisal_Name varchar(100)
		,@Main_KPI varchar(100)
		,@Sub_KPI varchar(250)
		,@Attributes varchar(500)
		,@Objective varchar(500)
		,@Status			varchar(250) 
		,@User_Id			numeric(18,0) = 0
		,@IP_Address		varchar(30)= '' 
		,@Row_No				numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare  @KPIPMS_ObjID	numeric(18,0) 
	declare @KPIPMS_ID		numeric(18,0)
	declare @KPIObj_ID		numeric(18,0)
	declare @Emp_ID			numeric(18,0)
	declare @KPI_Id			numeric(18,0)
	DECLARE @year  varchar(15)
	DECLARE @KPIPMS_Type	numeric(18,0)
	declare @SubKPIId		numeric(18,0)
	declare @EmpKPI_Id numeric(18,0)
	declare @KpiAtt_Id		numeric(18,0)
	declare @Branch_Id varchar(15)
	declare @Branch_Id1 varchar(15)
	
	SET @KPIPMS_Type =0 
	
		DECLARE @temp_data table
		(	
			 Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPIPMS_ObjID  varchar(50)
			,error_messge varchar(500)
		)
--Validations(start)
		if @FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,'',0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Financial Year is required',0,'Enter Financial Year',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
			end			
			
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id,@Branch_Id=Branch_Id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end	
			
			if exists(select isnull(Branch_Id,'')Branch_Id  from T0040_KPI_Master WITH (NOLOCK) where cmp_id=@cmp_id and Branch_Id like ('%' + @Branch_Id + '%') and Upper(KPI)=Upper(@Main_KPI))
			begin	
				if @Main_KPI=''
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge)values(0,'',0,'Main KPI is required')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,0,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Objective Status')						
						select * from  @temp_data
						return
					end	
				else if exists(select KPI_Id from t0040_KPI_Master WITH (NOLOCK) where Upper(KPI)=Upper(@Main_KPI) and cmp_id=@cmp_id)
					begin
						select @KPI_Id=KPI_Id from t0040_KPI_Master WITH (NOLOCK) where KPI=@Main_KPI
					end
				else
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_Code,0,'Main KPI does not Exist in System')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI does not Exist in System',0,'Enter Proper Main KPI',GetDate(),'KPI Objective Status')						
						select * from  @temp_data
						return
					end	
				end
			else
				begin
					insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI is required')
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Objective Status')						
					select * from  @temp_data
					return
				end		
			
		if exists(select EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @EmpKPI_Id=EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_Code,KPIPMS_ObjID,error_messge) values(0,@Emp_Code,0,'Employee KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee KPI does not Exist in System',0,'Employee KPI does not Exist in System',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end		
			
		if @Sub_KPI=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_code,0,'Sub KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Sub KPI does not Exist in System',0,'Enter Proper Sub KPI',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end
		else
			begin
				select @SubKPIId=SubKPIId from T0080_SubKPI_Master WITH (NOLOCK) where upper(Sub_KPI)=upper(@Sub_KPI) and Emp_Id=@Emp_Id and KPI_Id=@KPI_Id and cmp_id=@cmp_id and EmpKPI_Id=@EmpKPI_Id
			end	
				
		if @Appraisal_Type='Final'
			begin
				SET @KPIPMS_Type=2
			end	
		else if @Appraisal_Type='Interim'
			begin
				SET @KPIPMS_Type=1
			end						
					
		if @KPIPMS_Type=0
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,'',0,'Enter Proper Appraisal Type')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Enter Proper Appraisal Type',0,'Enter Proper Appraisal Type',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end				
			
		if @Appraisal_Name=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,'',0,'Enter Proper Appraisal Name')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Enter Proper Appraisal Name',0,'Enter Proper Appraisal Name',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end	
		else if exists(select KPIPMS_ID from  T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@Appraisal_Name) and KPIPMS_FinancialYr=@year and cmp_id=@cmp_id)
			begin
				select @KPIPMS_ID=KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@Appraisal_Name) and KPIPMS_FinancialYr=@year  and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_code,0,'Appraisal Name does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Appraisal Name does not Exist in System',0,'Enter Proper Appraisal Name',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end		
			
		if @Attributes=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_Code,0,'Attributes is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Attributes is required',0,'Enter Attributes',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end
		else if exists(select KpiAtt_Id from T0040_EmpKPI_Master WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KPI=@Attributes and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @KpiAtt_Id=KpiAtt_Id from T0040_EmpKPI_Master WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KPI=@Attributes and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_code,0,'KPI Attribute does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'KPI Attribute does not Exist in System',0,'Enter Proper KPI Attribute',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end		
				
		if @Objective=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_Code,0,'Objective is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Objective is required',0,'Enter Objective',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end
		else if exists(select KPIObj_ID from T0080_KPIObjectives WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KpiAtt_Id=@KpiAtt_Id  and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @KPIObj_ID=KPIObj_ID from T0080_KPIObjectives WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KpiAtt_Id=@KpiAtt_Id and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIPMS_ObjID,error_messge) values(0,@Emp_code,0,'Objective is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Objective is required',0,'Enter Proper KPI Objective',GetDate(),'KPI Objective Status')						
				select * from  @temp_data
				return
			end		
		
--Validations(end)			
			
			If Not exists(select 1 from T0090_KPIPMS_Objective WITH (NOLOCK) where Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id and KPIObj_ID=@KPIObj_ID and KPIPMS_ID=@KPIPMS_ID)
				Begin			
					select @KPIPMS_ObjID = isnull(max(KPIPMS_ObjID),0) + 1 from T0090_KPIPMS_Objective	WITH (NOLOCK)
					
					Insert into T0090_KPIPMS_Objective
					(
					   [KPIPMS_ObjID]
					  ,[Cmp_Id]
					  ,[KPIPMS_ID]
					  ,[KPIObj_ID]
					  ,[Emp_ID]
					  ,[Status]
					)
					Values
					(
						 @KPIPMS_ObjID
						,@Cmp_Id
						,@KPIPMS_ID
						,@KPIObj_ID
						,@Emp_ID
						,@Status
					)
				end
		End

