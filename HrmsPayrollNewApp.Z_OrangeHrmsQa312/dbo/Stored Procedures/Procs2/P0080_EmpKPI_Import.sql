


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0080_EmpKPI_Import]
	@Cmp_Id		numeric(18,0)
	,@Emp_Code		varchar(100)
	,@FinancialYr	varchar(30)
	,@Main_KPI		varchar(250) 
	,@SubKPI		varchar(250) 
	,@Weightage		numeric(18,2)
	,@CreatedBy		numeric(18,0) = 0
	,@IP_Address	 varchar(30)= '' 
	,@Row_No numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		declare @Emp_Id numeric(18,0)
		declare @EmpKPI_Id		numeric(18,0)
		declare @year  varchar(15)
		declare @SubKPI_Id numeric(18,0)
		declare @Branch_Id varchar(15)
		declare @Branch_Id1 varchar(15)
		--declare @KPI_Id numeric(18,0)
		
		declare @temp_data table
		(	
			Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,EmpKPI_Id  varchar(50)
			,error_messge varchar(500)
		)
		
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id,@Branch_Id=Branch_Id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(0,@Emp_Code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
		
		if @FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@FinancialYr, charindex('-', @FinancialYr) - 1)
			end		
			
	if exists(select isnull(Branch_Id,'')Branch_Id  from T0040_KPI_Master WITH (NOLOCK) where cmp_id=@cmp_id and Branch_Id like ('%' + @Branch_Id + '%') and Upper(KPI)=Upper(@Main_KPI))
		begin	
			if @Main_KPI='' and @Branch_Id1=''
					begin
						insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI is required')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required for this branch',0,'Enter Main KPI',GetDate(),'Main KPI')						
						select * from  @temp_data
						return
					end	
				else  if not exists(select KPI_Id from t0040_KPI_Master WITH (NOLOCK) where Upper(KPI)=Upper(@Main_KPI) and cmp_id=@cmp_id)
					begin
						insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge)  values(@Emp_Id,@Emp_Code,0,'Main KPI does not Exist in System')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,0,'Main KPI does not Exist in System',0,'Enter Proper Main KPI',GetDate(),'Main KPI')						
						select * from  @temp_data
						return
					end
		end
	else
		begin
			insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI is required')
			Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
			Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required for this branch',0,'Enter Main KPI',GetDate(),'Main KPI')						
			select * from  @temp_data
			return
		end	
			
		if @SubKPI=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge)values(@Emp_Id,@Emp_Code,0,'Sub KPI is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Sub KPI is required',0,'Enter Sub KPI',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
			
		if @Weightage=0
			begin
				insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Weightage is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Weightage is required',0,'Enter Weightage',GetDate(),'Main KPI')						
				select * from  @temp_data
				return
			end	
																		
			If Not exists(select 1 from T0080_EmpKPI WITH (NOLOCK) where Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id and FinancialYr=@year )
				Begin					
					Select @EmpKPI_Id = isnull(max(EmpKPI_Id),0) + 1 from T0080_EmpKPI WITH (NOLOCK)
					Insert Into T0080_EmpKPI
					(
						 EmpKPI_Id
						,Cmp_Id
						,Emp_Id
						,Status
						,FinancialYr
						,CreatedDate
						,CreatedBy
						,Emp_Comments
						,Mgr_Comments
						,HR_Comments
					)
					Values
					(
						 @EmpKPI_Id
						,@Cmp_Id
						,@Emp_Id
						,0
						,@year
						,GETDATE()
						,@CreatedBy
						,''
						,''
						,''
					)
					
					insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,@EmpKPI_Id,'')
					select * from  @temp_data
					return
				End
			else
				begin
					select @EmpKPI_Id=EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id and FinancialYr=@year 
					insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,@EmpKPI_Id,'')
					select * from  @temp_data
					return
				end
				
				
				
		--else
		--		begin
		--			insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Already exist')
		--			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Already exist',0,'Already exist',GetDate(),'Main KPI')						
		--			select * from  @temp_data
		--			return
		--		End
			
			--select @SubKPI_Id = isnull(max(SubKPIId),0) + 1 from T0080_SubKPI_Master
				
			-- if exists(select KPI_Id from t0040_KPI_Master where Upper(KPI)=Upper(@Main_KPI) and cmp_id=@cmp_id)
			--	begin
			--		select @KPI_Id=KPI_Id from t0040_KPI_Master where KPI=@Main_KPI
			--	end
			--else
			--	begin
			--		insert into @temp_data (Emp_Id,Emp_code,EmpKPI_Id,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI does not Exist in System')
			--		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Main KPI does not Exist in System',0,'Enter Proper Main KPI',GetDate(),'Main KPI')						
			--		select * from  @temp_data
			--		return
			--	end		
				
			--	INSERT INTO T0080_SubKPI_Master
			--	(
			--		 SubKPIId
			--		,EmpKPI_Id
			--		,Sub_KPI
			--		,Weightage
			--		,Cmp_Id
			--		,Emp_Id
			--		,KPI_Id
			--	)
			--	Values
			--	(
			--		 @SubKPI_Id
			--		,@EmpKPI_Id
			--		,@SubKPI
			--		,@Weightage
			--		,@Cmp_ID
			--		,@Emp_Id
			--		,@KPI_Id
			--	)
				
	End


