



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_Cost_Category_Detail] 
   @Tran_ID numeric(18,0) output
  ,@Cmp_ID  numeric(18,0)
  ,@Sal_Exp_ID numeric(18,0)
  ,@Cost_Center_ID numeric(18,0)
  ,@Sal_Exp_Tran_ID numeric(18,0)
  ,@Amount	numeric(18,0)
  ,@Tran_type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if  @Tran_type='I'
	  Begin 
				select @Tran_ID =  Isnull(max(Tran_ID),0) + 1  from T0080_Cost_Center_Detail WITH (NOLOCK)
	 
	 			insert into T0080_Salary_Export_Cost_Detail
	 				(Tran_ID, Cmp_Id ,Sal_Exp_ID, Cost_Center_ID,  Sal_Tran_Exp_ID, Amount)
				values(@Tran_ID, @Cmp_Id , @Sal_Exp_ID, @Cost_Center_ID,  @Sal_Exp_Tran_ID, @Amount)
	  End
	  
	 Else if @Tran_type='U'
	 
	 Update T0080_Salary_Export_Cost_Detail
	 
	   set Sal_Exp_ID=@Sal_Exp_ID,
	        Cost_Center_ID=@Cost_Center_ID,
	        Sal_Tran_Exp_ID=@Sal_Exp_Tran_ID,
	        Amount=@Amount
	        
	        Where Tran_ID=@Tran_ID
		   
	 
	RETURN




