-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 28/04/2017
-- Description:	Assign Uniform to Employee
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Uniform_Emp_Issue] 
	@Uni_Apr_Id Numeric(18,0) output,
	@Cmp_ID	Numeric(18,0),	
	@Emp_ID	Numeric(18,0),	
	@Issue_Date	Datetime,	
	@Uni_Id	Numeric(18,0),	
	@Uni_Pieces	Numeric(18,0),	
	@Uni_Rate	Numeric(18,2),	
	@Uni_Amount	Numeric(18,2),	
	@Uni_deduct_Installment	Numeric(18,0),
	@Uni_Refund_Installment	Numeric(18,0),
	@trantype varchar(1),
	@Modify_By	Varchar(100),	
	@Ip_Address	Varchar(100)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--if @Uni_deduct_Installment = 0
	-- set @Uni_deduct_Installment=1
	 
	--if @Uni_Refund_Installment = 0
	-- set @Uni_Refund_Installment=1
	  
	if @trantype = 'I'
		Begin
			if Exists(SELECT 1 From T0100_Uniform_Emp_Issue WITH (NOLOCK) Where Emp_ID = @Emp_ID AND Issue_Date = @Issue_Date and Uni_ID = @Uni_Id)
				BEGIN
					Set @Uni_Apr_Id = 0
					RAISERROR ('Record Already Exist', 16, 2)
					return
				End
			Select @Uni_Apr_Id = Isnull(Max(Uni_Apr_Id),0) + 1 From T0100_Uniform_Emp_Issue WITH (NOLOCK)
			Insert into T0100_Uniform_Emp_Issue(
				Uni_Apr_Id,Cmp_ID,Emp_ID,Issue_Date,
				Uni_Id,Uni_Pieces,Uni_Rate,Uni_Amount,Uni_deduct_Installment,
				Uni_deduct_Amount,Uni_Refund_Installment,Uni_Refund_Amount,
				Deduct_Pending_Amount,Refund_Pending_Amount,
				Modify_By,Modify_Date,Ip_Address)
			VALUES(
				@Uni_Apr_Id,@Cmp_ID,@Emp_ID,@Issue_Date,
				@Uni_Id,@Uni_Pieces,@Uni_Rate,@Uni_Amount,@Uni_deduct_Installment,
				Case When @Uni_deduct_Installment <> 0 Then Round((@Uni_Amount/@Uni_deduct_Installment),0) ELSE 0 END,
				@Uni_Refund_Installment,
				Case When @Uni_Refund_Installment <> 0 Then Round((@Uni_Amount/@Uni_Refund_Installment),0) ELSE 0 END,
				@Uni_Amount,@Uni_Amount,@Modify_By,Getdate(),@Ip_Address
			)
		End
	Else if @trantype = 'D'
		Begin
			if Exists(SELECT 1 From T0210_Uniform_Monthly_Payment WITH (NOLOCK) Where Uni_Apr_Id = @Uni_Apr_Id)
				BEGIN
					set @Uni_Apr_Id = 0
					return 
				End
			Delete From T0100_Uniform_Emp_Issue Where Emp_ID = @Emp_ID AND Uni_Apr_Id = @Uni_Apr_Id
		End
END
