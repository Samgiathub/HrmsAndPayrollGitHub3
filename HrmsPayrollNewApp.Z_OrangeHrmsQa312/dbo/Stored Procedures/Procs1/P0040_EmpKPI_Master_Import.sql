


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_EmpKPI_Master_Import]
    @Cmp_Id			numeric(18,0)
	,@Main_KPI			varchar(250) 
	,@Emp_code			varchar(50) 
	,@Attributes		varchar(500)
	,@SubKPI			varchar(250) 
    ,@User_Id			numeric(18,0) = 0
	,@IP_Address		varchar(30)= '' 
	,@FinancialYr	varchar(30)
	,@Row_No numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	declare @KpiAtt_Id	numeric(18,0) 
	declare @EmpKPI_Id	numeric(18,0)
	declare @KPI_Id	numeric(18,0)
	declare @Emp_Id		numeric(18,0)
	declare @SubKPIId	numeric(18,0)
	declare @year  varchar(15)
	declare @Branch_Id varchar(15)
	declare @Branch_Id1 varchar(15)
	
	declare @temp_data table
		(	
			Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPIAtt_Id  varchar(50)
			,error_messge varchar(500)
		)
				
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id) --to fetch emp_code(start)
			begin
				select @Emp_Id=emp_id,@Branch_Id=Branch_Id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(0,@Emp_Code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end		
	--to fetch emp_code(end)
	
		if @Attributes=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(0,@Emp_Code,0,'Attributes is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Attributes is required',0,'Enter Attributes',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end
			
		if @FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(0,'',0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
			end		
			
		--to fetch KPI_Id(start)	
		if exists(select isnull(Branch_Id,'')Branch_Id  from T0040_KPI_Master WITH (NOLOCK) where cmp_id=@cmp_id and Branch_Id like ('%' + @Branch_Id + '%') and Upper(KPI)=Upper(@Main_KPI))
		begin	
			if @Main_KPI=''
				begin
					insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge)values(0,'',0,'Main KPI is required')
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Attributes')						
					select * from  @temp_data
					return
				end	
			else if exists(select KPI_Id from t0040_KPI_Master WITH (NOLOCK) where Upper(KPI)=Upper(@Main_KPI) and cmp_id=@cmp_id)
				begin
					select @KPI_Id=KPI_Id from t0040_KPI_Master WITH (NOLOCK) where KPI=@Main_KPI
				end
			else
				begin
					insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(0,@Emp_Code,0,'Main KPI does not Exist in System')
					Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
					Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI does not Exist in System',0,'Enter Proper Main KPI',GetDate(),'KPI Attributes')						
					select * from  @temp_data
					return
				end		
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end	
		--to fetch KPI_Id(end)
		
		--to fetch SubKPIId(start)			
		if @SubKPI=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPIAtt_Id,error_messge)values(0,'',0,'Sub KPI is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Sub KPI is required',0,'Enter Sub KPI',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end	
		else if exists(select SubKPIId from T0080_SubKPI_Master WITH (NOLOCK) where  Emp_Id=@Emp_Id and Upper(Sub_KPI)=Upper(@SubKPI) and cmp_id=@cmp_id)
			begin
				select @SubKPIId=SubKPIId from T0080_SubKPI_Master WITH (NOLOCK) where  Emp_Id=@Emp_Id and Upper(Sub_KPI)=Upper(@SubKPI) and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_Code,KPIAtt_Id,error_messge) values(0,@Emp_Code,0,'Sub KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Sub KPI does not Exist in System',0,'Enter Proper Sub KPI',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end		
	--to fetch @SubKPIId(end)
	
	--to fetch EmpKPI_Id(start)
		if exists(select EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @EmpKPI_Id=EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_Code,KPIAtt_Id,error_messge) values(0,@Emp_Code,0,'Employee KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee KPI does not Exist in System',0,'Employee KPI does not Exist in System',GetDate(),'KPI Attributes')						
				select * from  @temp_data
				return
			end		
	--to fetch EmpKPI_Id(end)
			
					select @KpiAtt_Id	 = isnull(max(KpiAtt_Id	),0) + 1 from T0040_EmpKPI_Master WITH (NOLOCK)	
					Insert into T0040_EmpKPI_Master
					(
					   KpiAtt_Id	
					  ,EmpKPI_Id
					  ,Cmp_Id					 
					  ,Emp_Id
					  ,KPI
					  ,Weightage
					  ,SubKPIId
					)
					Values
					(
					   @KpiAtt_Id		
					  ,@EmpKPI_Id
					  ,@Cmp_Id					  
					  ,@Emp_Id
					  ,@Attributes
					  ,0
					  ,@SubKPIId
					)
				End



