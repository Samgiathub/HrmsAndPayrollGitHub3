

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 11012017	
-- Description:	For Car Retention
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0110_Car_Retention]
	-- Add the parameters for the stored procedure here
	 @Tran_ID Numeric output,
     @Cmp_ID Numeric,
     @Emp_ID Numeric,
     @AD_ID Numeric,
     @AD_Amount Numeric(18,4),
	 @AD_Month Numeric(18,0),
     @Effective_Date DateTime,
	 @Tran_type Varchar(10),
     @Login_ID Numeric = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	if @Tran_type = 'I'
		Begin
			if Exists(Select 1 From T0110_Car_Retention WITH (NOLOCK) Where Emp_ID = @Emp_ID and AD_ID = @AD_ID and Effective_Date = @Effective_Date)
				Begin
					Update T0110_Car_Retention
					Set Effective_Date = @Effective_Date,
						AD_Amount = @AD_Amount,
						Sys_DateTime = GetDate(),
						Login_ID = @Login_ID ,
						No_of_Month = @AD_Month
					Where Emp_ID = @Emp_ID and AD_ID = @AD_ID and Effective_Date = @Effective_Date
				End
			Else
				Begin
					Select @Tran_ID = isnull(max(Tran_ID),0) + 1 From T0110_Car_Retention  WITH (NOLOCK)

					Insert into T0110_Car_Retention
						(Tran_ID,Cmp_ID,Emp_ID,AD_ID,AD_Amount,Effective_Date,Sys_DateTime,Login_ID,No_of_Month)
					Values(@Tran_ID,@Cmp_ID,@Emp_ID,@AD_ID,@AD_Amount,@Effective_Date,getdate(),@Login_ID,@AD_Month)
				End
		End
	if @Tran_type = 'D'
		Begin
			if Exists(Select 1 From T0200_Monthly_Salary WITH (NOLOCK) Where @Effective_Date Between Month_St_Date AND Month_End_Date and Emp_ID = @Emp_ID)
				Begin
					RAISERROR('Employee Salary Exists.',16,1);
					return
				End
			Delete From T0110_Car_Retention Where Tran_ID = @Tran_ID and Emp_ID = @Emp_ID and Effective_Date =  @Effective_Date and AD_ID = @AD_ID
		End
END

