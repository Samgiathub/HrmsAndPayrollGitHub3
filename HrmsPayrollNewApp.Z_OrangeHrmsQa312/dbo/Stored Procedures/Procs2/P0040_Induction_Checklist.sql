


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 11-10-2018
-- Description:	Create Checklist for Induction Training
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Induction_Checklist] 
	-- Add the parameters for the stored procedure here
	@Checklist_ID Numeric(18,0) Output,
	@Checklist_Name Varchar(200),
	@Sort_ID Numeric,
	@Cmp_ID Numeric,
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
			Select @Checklist_ID = Isnull(Max(Checklist_ID),0) + 1 From T0040_Induction_Checklist WITH (NOLOCK)
			
			IF Exists(Select 1 From T0040_Induction_Checklist WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Checklist_Name) = Upper(@Checklist_Name))
				Begin 
					Set @Checklist_ID = 0
					return
				END
			Insert into T0040_Induction_Checklist(Checklist_ID,Checklist_Name,Sort_ID,Cmp_ID,Modify_Date,Modify_By,IP_Address) 
			VALUES(@Checklist_ID,@Checklist_Name,@Sort_ID,@Cmp_ID,GETDATE(),@User_Id,@IP_Address)
		End
	Else if @Trans_Type = 'U'
		Begin
			Update TC
				SET TC.Checklist_Name = @Checklist_Name,
					TC.Sort_ID = @Sort_ID,
				    TC.Modify_Date = GETDATE(),
				    TC.Modify_By = @User_Id,
				    TC.Ip_Address = @IP_Address
			From T0040_Induction_Checklist TC Where Checklist_ID = @Checklist_ID
		End
	Else if @Trans_Type = 'D'
		Begin
			Delete From T0040_Induction_Checklist Where Checklist_ID = @Checklist_ID 
		End
END

