



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_salary_Export_Cost_Detail] 
   @Tran_ID numeric(18,0) output
  ,@Cmp_ID  numeric(18,0)
  ,@Sal_Exp_ID numeric(18,0)
  ,@Cost_Center_ID numeric(18,0)
  ,@Sal_Exp_Trn_ID numeric(18,0)
  ,@Amount	numeric(18,3)
  ,@Tally_Led_Name Varchar(50)
  ,@Led_Amount   numeric(18,2)
  ,@Tran_type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	--if @Sal_Exp_Trn_ID =0 
	--set @Sal_Exp_Trn_ID =null
	
--	if @Sal_Exp_ID =0 
--	set @Sal_Exp_ID =null

	if  @Tran_type='I'
	  Begin 
				
			select @Tran_ID =  Isnull(max(Tran_ID),0) + 1  from T9999_Salary_Export_Cost_Detail WITH (NOLOCK)
	 
	 	
	 	Begin 
	 		Select @Sal_Exp_ID=Sal_Exp_ID,@Sal_Exp_Trn_ID=Sal_Exp_Trn_ID from T9999_salary_Export_Detail WITH (NOLOCK)
			 where Tally_Led_name = @Tally_Led_Name and cmp_ID=@Cmp_ID and Dr_Amount =@Led_Amount
	     end
			 
			 
			 
	 			insert into T9999_Salary_Export_Cost_Detail
	 				(Tran_ID, Cmp_Id ,Sal_Exp_ID, Cost_Center_ID,  Sal_Exp_Trn_ID, Amount)
				values(@Tran_ID, @Cmp_Id , @Sal_Exp_ID, @Cost_Center_ID,  @Sal_Exp_Trn_ID, @Amount)
						 
				
	  End
	  
	 Else if @Tran_type='U'
	 
	 Update T9999_Salary_Export_Cost_Detail
	 
	   set Sal_Exp_ID=@Sal_Exp_ID,
	        Cost_Center_ID=@Cost_Center_ID,
	        Sal_Exp_Trn_ID=@Sal_Exp_Trn_ID,
	        Amount=@Amount    
	        Where Tran_ID=@Tran_ID
		   
	 
	RETURN




