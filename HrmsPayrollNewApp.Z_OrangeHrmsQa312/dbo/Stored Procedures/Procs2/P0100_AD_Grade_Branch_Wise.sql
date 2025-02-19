

-- =============================================
-- Author:		Patel Nilesh 
-- Create date: 30-08-2017
-- Description:	Allowance Assign Grade & Branch Wise
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_AD_Grade_Branch_Wise] 
	-- Add the parameters for the stored procedure here
	@Tran_ID Numeric(18,0) Output,
	@Cmp_ID Numeric(18,0),
	@AD_ID Numeric(18,0),
	@Effective_Date Datetime,
    @Grd_ID Numeric(18,0),
    @Branch_ID Numeric(18,0),
    @AD_Amount Numeric(18,2),
    @UserID Numeric(18,0),
    @Calculate_on varchar(100),
    @Trantype Char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	if @Trantype = 'I'
		Begin
			if Exists(Select 1 From T0100_AD_Grade_Branch_Wise WITH (NOLOCK) Where AD_ID = @AD_ID and Grd_ID = @Grd_ID and Branch_ID = @Branch_ID and Effective_Date = @Effective_Date)
				BEGIN
					RAISERROR('@@Same Date Record Exists.@@',16,2)
					return
				End
			
			Select @Tran_ID = Isnull(MAX(Tran_ID),0) + 1 From T0100_AD_Grade_Branch_Wise WITH (NOLOCK)
			
			Insert into T0100_AD_Grade_Branch_Wise
				(
					Tran_ID,
					Cmp_ID,
					AD_ID,
					Effective_Date,
					Grd_ID,
					Branch_ID,
					AD_Amount,
					AD_CALCULATE_ON,
					SysDatetime,
					UserID
				)
			VALUES(
					@Tran_ID,
					@Cmp_ID,
					@AD_ID,
					@Effective_Date,
					@Grd_ID,
					@Branch_ID,
					@AD_Amount,
					@Calculate_on,
					GETDATE(),
					@UserID
				)
		End
	Else if @Trantype = 'U'
		Begin
			Update T0100_AD_Grade_Branch_Wise
				Set 
				   AD_Amount = @AD_Amount,
				   AD_CALCULATE_ON = @Calculate_on
			Where Tran_ID = @Tran_ID and Grd_ID = @Grd_ID and Branch_ID = @Branch_ID
		End
	Else if @Trantype = 'D'
		Begin
			Select @AD_ID = Isnull(AD_ID,0) From T0100_AD_Grade_Branch_Wise WITH (NOLOCK) Where Tran_ID = @Tran_ID
			If Exists(SELECT 1 From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) Where AD_ID = @AD_ID)
				BEGIN
					RAISERROR('@@Reference Exist Records Should not be Delete.@@',16,2)
					return
				End
			
			If Exists(SELECT 1 From T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK) Where AD_ID = @AD_ID)
				BEGIN
					RAISERROR('@@Reference Exist Records Should not be Delete.@@',16,2)
					return
				End
			Delete From T0100_AD_Grade_Branch_Wise Where Tran_ID = @Tran_ID
		End
END

