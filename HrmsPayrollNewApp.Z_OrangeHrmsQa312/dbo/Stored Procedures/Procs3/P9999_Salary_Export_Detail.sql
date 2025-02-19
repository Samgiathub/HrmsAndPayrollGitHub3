


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P9999_Salary_Export_Detail]
	 @Sal_Exp_Id 		numeric(18) 
	,@Cmp_Id 			numeric(18)
	,@Sal_Exp_Trn_Id	numeric(18)output
	,@Emp_Id  			numeric(18)
	,@Tally_Led_Name 	varchar(100)
	,@Dr_Amount 		numeric(18,2)
	,@Cr_Amount			numeric(18,2)
	,@Comment			varchar(100)
	,@Trans_Type 		char(1)
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Trans_Type ='i' 
		begin
			if @Emp_Id = 0
				set @Emp_Id = null
				
				--if exists (Select Sal_Exp_Trn_Id  from T9999_Salary_Export_Detail Where Sal_Exp_Trn_Id = @Sal_Exp_Trn_Id and Sal_Exp_Id = @Sal_Exp_Id) 
				--begin
					--set @Sal_Exp_Trn_Id = 0
				--end
			--else
				--begin

				select @Sal_Exp_Trn_Id =  Isnull(max(Sal_Exp_Trn_Id),0) + 1  from T9999_Salary_Export_Detail WITH (NOLOCK)
					
					insert into T9999_Salary_Export_Detail(Sal_Exp_Id, Cmp_Id , Sal_Exp_Trn_Id ,emp_Id, Tally_Led_name, Dr_Amount,Cr_Amount, Comment)

					 values(@Sal_Exp_Id, @Cmp_Id , @Sal_Exp_Trn_Id , @emp_Id, @Tally_Led_name, @Dr_Amount,@Cr_Amount, @Comment)
					 
		        	 
			--	end
		end

	else if @Trans_Type ='u' 
		begin
				Update T9999_Salary_Export_Detail Set Tally_Led_name = @Tally_Led_name , Dr_Amount = @Dr_Amount , Cr_Amount = @Cr_Amount, comment = @Comment where Sal_Exp_Trn_Id = @Sal_Exp_Trn_Id 

		end	
	else if @Trans_Type ='d' 
		begin
			delete  from T9999_Salary_Export_Detail where Sal_Exp_Trn_Id = @Sal_Exp_Trn_Id 
		end	

	RETURN




