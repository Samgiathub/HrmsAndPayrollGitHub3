

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 22-10-2018
-- Description:	For Fill HR Checklist Employee Wise
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EMP_WISE_CHECKLIST]
	@Checklist_ID Numeric Output,
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Training_ID Numeric,
	@Training_Tran_ID Numeric,
	@Training_Date Datetime,
	@Fill_Up_CheckList Varchar(100),
	@Not_Req_Checklist Varchar(100),
	@Fill_Details Varchar(1000),
	@Trans_Type Char(1),
	@User_Id Numeric,
	@IP_Address Varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Trans_Type = 'I'
		Begin
			IF Exists(SELECT 1 From T0050_EMP_WISE_CHECKLIST WITH (NOLOCK) Where Emp_ID = @Emp_ID and Tran_ID = @Training_Tran_ID and Fill_Date = @Training_Date)
				BEGIN
					RAISERROR('@@Same Training checklist are submitted successfully@@.',16,2)
					return 0
				END
			Select @Checklist_ID = ISNULL(Max(Checklist_ID),0) + 1 From T0050_EMP_WISE_CHECKLIST WITH (NOLOCK)
			
			Insert Into T0050_EMP_WISE_CHECKLIST
				(Checklist_ID,Cmp_ID,Emp_ID,Fill_Date,Training_ID,Tran_ID,Fill_Up_Checklist,Not_Req_Checklist,Fill_Details,Modify_Date,Modify_By,Ip_Address)
			VALUES(@Checklist_ID,@Cmp_ID,@Emp_ID,@Training_Date,@Training_ID,@Training_Tran_ID,@Fill_Up_CheckList,@Not_Req_Checklist,@Fill_Details,GETDATE(),@User_Id,@IP_Address)
		End
	Else If @Trans_Type = 'U'
		Begin
			Update T0050_EMP_WISE_CHECKLIST
				Set 
					Fill_Up_Checklist = @Fill_Up_CheckList,
					Not_Req_Checklist = @Not_Req_Checklist,
					Modify_Date = GETDATE(),
					Modify_By = @User_Id,
					Ip_Address = @IP_Address,
					Fill_Details = @Fill_Details
			Where Checklist_ID = @Checklist_ID 
		End
	Else if @Trans_Type = 'D'
		Begin
			Delete From T0050_EMP_WISE_CHECKLIST Where Checklist_ID = @Checklist_ID and Emp_ID = @Emp_ID
		End	
END

