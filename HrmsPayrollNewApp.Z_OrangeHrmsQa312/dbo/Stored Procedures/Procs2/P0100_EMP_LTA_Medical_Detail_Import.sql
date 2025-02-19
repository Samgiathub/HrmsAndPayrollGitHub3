



-- =============================================
-- Author:		Zalak
-- ALTER date: 01042011
-- Description:	for import of LTA medical detail which return value in table 
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_LTA_Medical_Detail_Import]

  @emp_code  as varchar(50)
 ,@cmp_id as numeric(18,0)
 ,@from_date as datetime
 ,@To_date	as datetime 
 ,@Type	 as varchar(50)
 ,@Mode	as char(1)
 ,@Amount as numeric(18,2)
 ,@effective_month as varchar(50)
 ,@Effect_on_CTC as int	
 ,@Cal_amount_Type	 as varchar(50)
 ,@Show_Yearly	as int
 ,@carry_fw_amount	as numeric(18,2)
 ,@no_it_claims as int
 ,@Max_limit as numeric(18,2) 

 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @temp_data table
		(
			emp_code  varchar(50)
			,error_messge varchar(500)
			,Status  int
		)
		
		declare @LM_ID as numeric(18,0)
		declare @Type_id as int
		declare @Cal_amount_Type_id as int
		declare @branch_id as numeric(18,0)
		declare @emp_id as numeric(18,0)
		declare @increment_effective_date as datetime
		
		if exists(select top 1 emp_id from t0095_increment WITH (NOLOCK) where cmp_id=@cmp_id and emp_id in (select emp_id from t0080_emp_master WITH (NOLOCK) where cast(emp_code as varchar(50))=@emp_code and cmp_id=@cmp_id) and increment_effective_date<= @to_date order by increment_effective_date desc)
			select top 1 @branch_id=branch_id,@emp_id=emp_id,@increment_effective_date=increment_effective_date from t0095_increment WITH (NOLOCK) where cmp_id=@cmp_id and emp_id in (select emp_id from t0080_emp_master WITH (NOLOCK) where cast(emp_code as varchar(50))=@emp_code and cmp_id=@cmp_id) and increment_effective_date<= @to_date order by increment_effective_date desc		
		else
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,upper(@emp_code) + ' : Employee Code not Exit in Employee Master',0)
				select * from  @temp_data
				return
			end
		if upper(@Type)<>'LTA' and upper(@Type)<>'MEDICAL'
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,upper(@Type) + ' : Type Should be LTA or Medical which is not proper',0)
				select * from  @temp_data
				return
			end
		else if upper(@Type)='LTA'
			set @type_id=1
		else if upper(@Type)= 'MEDICAL'
			set @type_id=2
			
		if upper(@mode)<>'%' and upper(@mode)<>'R' and upper(@mode)<>'F'
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,upper(@mode) + ' : Mode Should be % or R or F which is not proper',0)
				select * from  @temp_data
				return
			end
		if replace(upper(@Cal_amount_Type),' ','')<>'BASICSALARY' and replace(upper(@Cal_amount_Type),' ','')<>'GROSSSALARY'
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,upper(@Cal_amount_Type) + ' : Cal_amount_Type Should be Basic Salary or Gross Salary which is not proper',0)
				select * from  @temp_data
				return
			end
		else if replace(upper(@Cal_amount_Type),' ','')='BASICSALARY'
			set @Cal_amount_Type_id=1
		else if replace(upper(@Cal_amount_Type),' ','')='GROSSSALARY'
			set @Cal_amount_Type_id=2
			
		if left(@effective_month,1)<>'#' or right(@effective_month,1)<>'#'
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,@effective_month + ' : Effective_month Should be #month number#  which is not proper',0)
				select * from  @temp_data
				return
			end
		if @Show_Yearly <>0 and @Show_Yearly <>1
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,'Show_Yearly Should be 0 or 1 which is not proper',0)
				select * from  @temp_data
				return
			end
		if @Effect_on_CTC <>0 and @Effect_on_CTC<>1
			begin
				insert into @temp_data (emp_code,error_messge,Status) values(@emp_code,'Effect_on_CTC Should be 0 or 1 which is not proper',0)
				select * from  @temp_data
				return
			end
		if exists(select row_id from t0040_lm_setting WITH (NOLOCK) where type_id=@type_id and  Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,0)  and( (@From_Date >= start_date and @From_Date <= end_date) or (@from_Date >= start_date and 	@To_Date <= end_date) or (start_date >= @from_Date and start_date <= @To_Date) or(end_date >= @from_Date and end_date <= @To_Date)))
			begin
				select @from_date=start_date,@to_date=end_date from t0040_lm_setting WITH (NOLOCK) where type_id=@type_id and  Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,0)  and( (@From_Date >= start_date and @From_Date <= end_date) or (@from_Date >= start_date and 	@To_Date <= end_date) or (start_date >= @from_Date and start_date <= @To_Date) or(end_date >= @from_Date and end_date <= @To_Date))
				exec P0100_EMP_LTA_Medical_Detail @LM_ID output,@Cmp_ID,@Emp_ID,@from_date,@to_date,@Mode,@Amount,@type_id,@Carry_fw_amount,@no_IT_claims,'I'
				if @LM_ID=0
					insert into @temp_data (emp_code,error_messge,Status)values(@emp_code,'Employee Data exists',0)
				else
					insert into @temp_data (emp_code,error_messge,Status)values(@emp_code,'Successfully Inserted',1)
			end
		else
			begin
				declare @row_id as numeric(18,0)
				exec P0040_LM_SETTING @row_id output,@Cmp_ID,@Branch_id,@from_date,@from_date,@to_date,@Max_limit,@Type_ID,@Effective_month,@Effect_on_CTC,@Cal_amount_Type_id,@Show_Yearly,'I'
				if @row_id=0
					insert into @temp_data (emp_code,error_messge,Status)values(@emp_code,'Master Data exists',0)
				else
					begin
						exec P0100_EMP_LTA_Medical_Detail @LM_ID output,@Cmp_ID,@Emp_ID,@from_date,@to_date,@Mode,@Amount,@type_id,@Carry_fw_amount,@no_IT_claims,'I'
						if @LM_ID=0
							insert into @temp_data (emp_code,error_messge,Status)values(@emp_code,'Employee Data exists',0)
						else
							insert into @temp_data (emp_code,error_messge,Status)values(@emp_code,'Successfully Inserted',1)
					end
			end
		select * from  @temp_data	
			
RETURN



