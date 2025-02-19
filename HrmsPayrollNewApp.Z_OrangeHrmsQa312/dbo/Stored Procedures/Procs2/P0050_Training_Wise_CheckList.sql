


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 11-10-2018
-- Description:	Create Checklist for Induction Training
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Training_Wise_CheckList] 
	-- Add the parameters for the stored procedure here
	@Tran_ID Numeric(18,0) Output,
	@Cmp_ID Numeric,
	@Training_ID Numeric,
	@Effective_Date Datetime,
	@Assign_CheckList Varchar(1000),
	@Trans_Type Char(1),
	@User_Id Numeric(18,0),
	@IP_Address Varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    IF @Trans_Type = 'I'
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0050_Training_Wise_CheckList WITH (NOLOCK)
			
			IF Exists(Select 1 From T0050_Training_Wise_CheckList WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Training_ID = @Training_ID AND Effective_Date = @Effective_Date)
				Begin 
					SET @Tran_ID = 0
					return
				END
				
			Insert into T0050_Training_Wise_CheckList(Tran_ID,Cmp_ID,Training_ID,Effective_Date,Assign_CheckList,Modify_Date,Modify_By,IP_Address) 
			VALUES(@Tran_ID,@Cmp_ID,@Training_ID,@Effective_Date,@Assign_CheckList,GETDATE(),@User_Id,@IP_Address)
		End
	Else if @Trans_Type = 'U'
		Begin
			Update TC
				SET TC.Effective_Date = Effective_Date,
					TC.Assign_CheckList = @Assign_CheckList,
				    TC.Modify_Date = GETDATE(),
				    TC.Modify_By = @User_Id,
				    TC.Ip_Address = @IP_Address
			From T0050_Training_Wise_CheckList TC Where Tran_ID = @Tran_ID
		End
	Else if @Trans_Type = 'D'
		Begin
			Delete From T0050_Training_Wise_CheckList Where Tran_ID = @Tran_ID
		End
END

