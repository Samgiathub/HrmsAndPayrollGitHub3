

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_KPIObjectives_Import]
	 @Cmp_ID		numeric(18,0)
	,@Emp_Code		varchar(100)
	,@Main_KPI			varchar(250) 
	,@Objective		varchar(Max) 
	,@IP_Address	varchar(30)= ''
	,@FinancialYr	varchar(30)
	,@Attributes		varchar(500)
	,@Row_No numeric(18,0)
AS
Begin

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @KPIObj_Id		numeric(18,0)
	declare @KpiAtt_Id		numeric(18,0)
	declare @Emp_Id		numeric(18,0)
	declare @EmpKPI_Id		numeric(18,0)
	declare @year  varchar(15)
	declare @temp_data table
		(	
			Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPIObj_Id  varchar(50)
			,error_messge varchar(500)
		)
		
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,@Emp_code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end		
			
		if @Attributes=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,@Emp_Code,0,'Attributes is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Attributes is required',0,'Enter Attributes',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end
			
		if @Objective=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,@Emp_Code,0,'Objective is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Objective is required',0,'Enter Objective',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end
							
		if @FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,'',0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
			end					
	
		if @Main_KPI=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge)values(0,'',0,'Main KPI is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end	
		
	--to fetch EmpKPI_Id(start)
	if exists(select EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id)  
			begin
				select @EmpKPI_Id=EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,@Emp_code,0,'Employee KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee KPI does not Exist in System',0,'Employee KPI does not Exist in System',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end		
	--to fetch EmpKPI_Id(end)
	
	--to fetch KpiAtt_Id(start)
		if exists(select KpiAtt_Id from T0040_EmpKPI_Master WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KPI=@Attributes and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @KpiAtt_Id=KpiAtt_Id from T0040_EmpKPI_Master WITH (NOLOCK) where EmpKPI_Id=@EmpKPI_Id and KPI=@Attributes and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIObj_Id,error_messge) values(0,@Emp_code,0,'KPI Attribute does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'KPI Attribute does not Exist in System',0,'Enter Proper KPI Attribute',GetDate(),'KPI Objective & Metric')						
				select * from  @temp_data
				return
			end		
	--to fetch KpiAtt_Id(end)
				
				select @KPIObj_ID = isnull(max(KPIObj_ID),0) + 1 from T0080_KPIObjectives WITH (NOLOCK)
				INSERT INTO T0080_KPIObjectives
				(
					KPIObj_ID
					,Cmp_Id
					,KpiAtt_Id
					,Objective
					,Emp_ID
					,CreatedBy_Id
					,AddByFlag
					,Approve_Status
					,Verification_Status
					,EmpKPI_Id
					,Metric
				)
				Values
				(
					@KPIObj_Id
					,@Cmp_ID
					,@KpiAtt_Id
					,@Objective
					,@Emp_Id
					,0
					,''
					,''
					,''
					,@EmpKPI_Id
					,''
				)
				
			End



