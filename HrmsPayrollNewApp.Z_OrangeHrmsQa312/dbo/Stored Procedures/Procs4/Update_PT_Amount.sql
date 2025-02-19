



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Update_PT_Amount]
	@Cmp_ID						numeric, 
	@Emp_Id						numeric,
	@Increment_Id				numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Emp_PT as tinyint
	Declare @Basic_Salary as numeric(18,2)
	Declare @AD_Other_Amount as numeric(18,2)
	declare @Increment_effective_Date as datetime
	declare @PT_Amount as numeric(12,2)
	declare @Branch_ID as numeric
	
	Select @Emp_PT=Emp_PT,@Basic_Salary=Basic_Salary,@Increment_effective_Date=Increment_Effective_Date,@Branch_ID=Branch_ID from T0095_INCREMENT WITH (NOLOCK) where Increment_ID = @Increment_Id
	
	if @Emp_PT = 1
		begin
				Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				set @AD_Other_Amount = @Basic_Salary + isnull(@AD_Other_Amount,0)
				
			Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Increment_effective_Date,@AD_Other_Amount,@PT_Amount output,'',@Branch_ID
			
			Update T0095_INCREMENT set Emp_PT_Amount = @PT_Amount where Increment_ID = @Increment_Id and Emp_ID = @Emp_Id
			
		end
	
	
Return


