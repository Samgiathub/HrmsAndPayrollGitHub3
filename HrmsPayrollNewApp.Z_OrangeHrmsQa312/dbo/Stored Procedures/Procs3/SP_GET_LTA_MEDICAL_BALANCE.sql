



--zalak for lta medical application time balance
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LTA_MEDICAL_BALANCE]
	 @Cmp_ID	numeric(18, 0)	
	,@Emp_ID	numeric(18, 0)	
	,@APP_Date	datetime	
	,@type_ID	int
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @branch_id as numeric(18,0)
	declare @effective_month as varchar(100)
	declare @month as char(2)
	declare @show_yearly as int
	declare @accpected_balance as int
	declare @mode as char(1)
	declare @amount numeric(18,2)
	declare @basic_salary numeric(18,2)
	declare @gross_salary numeric(18,2)
	declare @end_Date as datetime
	declare @start_Date as datetime
	declare @max_limit as numeric(18,2)
	declare @Cal_amount_Type as int
	declare @Increment_Effective_Date as datetime
	
	declare @Type_Name varchar(50)	
	declare @pre_month as char(2)
	
	if @type_ID = 1
		set @Type_Name = 'LTA'
	else
	    set @Type_Name = 'Medical'	
	
	declare @temp table
	(
		type_name varchar(50)
		,bal_type varchar(50)
		,app_date datetime
		,balance_amount numeric(18,2)
	)
	
	select @Increment_Effective_Date=Increment_Effective_Date,@branch_id=branch_id,
	@basic_salary=basic_salary,@gross_salary=gross_salary  from t0095_increment I WITH (NOLOCK) inner join     
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
     where Increment_Effective_date <= @APP_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date    
    Where I.Emp_ID = @Emp_ID     
	
	select  @effective_month=effective_month,@show_yearly=show_yearly,@max_limit=max_limit,@Cal_amount_Type=Cal_amount_Type from T0040_LM_SETTING WITH (NOLOCK) where branch_id=@branch_id and start_date<=@APP_Date and end_date>=@APP_Date and type_id=@type_id
	select @mode=mode,@amount=amount,@end_Date=to_date,@start_Date=from_date from T0100_EMP_LTA_Medical_Detail WITH (NOLOCK) where emp_id=@emp_id and from_date<=@app_date and to_date>=@app_date
	
	
	set @pre_month = '0'
	
	Declare curLTAMedical cursor for Select data from dbo.Split(@effective_month,'#') 
	open curLTAMedical
		fetch next from curLTAMedical into @month
		while @@fetch_status = 0
	      begin
	      	if cast(@month as int)<= datepart(mm,@APP_Date) and cast(@month as int)<>0 
				begin	
												
					if @mode='%'
						begin						
							if @Cal_amount_Type=1
								set @accpected_balance = (@basic_salary * @amount/100) * (cast(@month as int)-cast(@pre_month as int))
							else
								set @accpected_balance = (@gross_salary * @amount/100) * (cast(@month as int)-cast(@pre_month as int))
								
							set @pre_month = @month	
						end
					else if @mode='F'
						begin													
							if @Cal_amount_Type=1
								set @accpected_balance = @basic_salary * @amount
							else
								set @accpected_balance = @gross_salary * @amount														
						end
					else
					   begin					   
								set @accpected_balance = @amount					
						end
						
					insert into @temp(type_name,bal_type,balance_amount) values (@Type_Name,'As On Period',@accpected_balance)
				end
			else if cast(@month as int)>= datepart(mm,@APP_Date) and cast(@month as int)<>0 
				begin
					
					if @mode='%'
						begin						
							if @Cal_amount_Type=1
								set @accpected_balance = (@basic_salary * @amount/100) * (cast(@month as int)-cast(@pre_month as int))
							else
								set @accpected_balance = (@gross_salary * @amount/100) * (cast(@month as int)-cast(@pre_month as int))
								
							set @pre_month = @month	
						end
					else if @mode='F'
						begin													
							if @Cal_amount_Type=1
								set @accpected_balance = @basic_salary * @amount
							else
								set @accpected_balance = @gross_salary * @amount														
						end
					else
					   begin					   
								set @accpected_balance = @amount					
						end
						
						insert into @temp(type_name,bal_type,balance_amount) values (@Type_Name,'Total',@accpected_balance)
			     end
			
			fetch next from curLTAMedical into @month
	      end
	 close curLTAMedical
	deallocate curLTAMedical
		
	declare @Total_Amt numeric(18,2)
		
	select type_name,bal_type,sum(balance_amount) as balance_amount from @temp group by bal_type,type_name
	
	select @Total_Amt = sum(balance_amount) from @temp 
	
	if @Total_Amt > @max_limit
		select @max_limit as balance_amount, @start_Date as from_date
	else
		select sum(balance_amount) as balance_amount, @start_Date as from_date from @temp 
	
	--select '','',@start_Date as from_date,balance_amount from @temp where bal_type='Total'
	
RETURN



