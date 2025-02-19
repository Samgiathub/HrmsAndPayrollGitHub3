

-- Created by rohit for bonus Deduction import on 19052016.
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0180_BONUS_Import]
   @Cmp_ID				NUMERIC(18,0)  
   ,@Emp_code			varchar(100)  
   ,@From_Date			DATETIME
   ,@To_Date			DATETIME
   ,@Punja_other_cust_bonus_paid Numeric(18,2) = 0 
   ,@Intrime_advance_bonus_paid Numeric(18,2) = 0 
   ,@Deduction_mis_Amount Numeric(18,2) = 0 
   ,@Income_Tax_on_Bonus Numeric(18,2) = 0 
   ,@Log_Status Int = 0 Output
   ,@Row_No Int
   ,@User_Id numeric(18,0) = 0
   ,@IP_Address varchar(30)= ''
   ,@GUID varchar(2000) = '' --Added by nilesh patel on 15062016
AS  
 	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	set DEADLOCK_PRIORITY LOW;
		
	DECLARE @Emp_ID			As NUMERIC(18,0)   
BEGIN

	select @emp_id = emp_id from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code and Cmp_ID=@Cmp_ID

	if ISNULL(@emp_id ,0)=0
		begin
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Employee Code not Exists',0,'Enter Proper Employee Code',GetDate(),'Bonus Deduction Import',@GUID)						
			SET @Log_Status=1			
			return
		end
	
	if @From_Date is null or @From_Date = ''
		Begin
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'From Date not Exists',0,'Enter From Date Details',GetDate(),'Bonus Deduction Import',@GUID)						
			SET @Log_Status=1			
			return
		End
	
	IF @To_Date is null or @To_Date = ''
		Begin
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'To Date not Exists',0,'Enter To Date Details',GetDate(),'Bonus Deduction Import',@GUID)						
			SET @Log_Status=1			
			return
		End

	if not exists (select 1 from T0180_BONUS WITH (NOLOCK) where Emp_ID=@Emp_ID and From_Date = @From_Date and To_Date = @To_Date) 
	begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Bonus Not Generated',0,'Bonus Not Generated For given Period ',GetDate(),'Bonus Deduction Import',@GUID)						
			SET @Log_Status=1			
			return

	end
	else
	Begin
		
		update T0180_BONUS 
		set Punja_other_cust_bonus_paid = isnull(@Punja_other_cust_bonus_paid,0) 
		,Intrime_advance_bonus_paid=isnull(@Intrime_advance_bonus_paid,0) 
		,Deduction_mis_Amount=isnull(@Deduction_mis_Amount,0) 
		,Income_Tax_on_Bonus =isnull(@Income_Tax_on_Bonus,0) 
		,Net_Payable_Bonus = (isnull(Bonus_Amount,0) + ISNULL(Ex_Gratia_Bonus_Amount,0) ) - (isnull(@Punja_other_cust_bonus_paid,0) + isnull(@Intrime_advance_bonus_paid,0) + isnull(@Deduction_mis_Amount,0) + isnull(@Income_Tax_on_Bonus,0))
		where Emp_ID=@Emp_ID and From_Date = @From_Date and To_Date = @To_Date 
	end

END

RETURN

