

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 22-08-2017
-- Description:	Ticket Approval
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Ticket_Approval]
	@Ticket_Apr_ID Numeric(18,0) Output,
    @Ticket_App_ID Numeric(18,0),
    @Cmp_ID Numeric(18,0),
    @Emp_ID Numeric(18,0),
    @Ticket_Type_ID Numeric(18,0),
    @Ticket_Gen_Date Datetime,
    --@Ticket_Apr_Date Datetime,
    @Ticket_Dept_ID Numeric(18,0),
    @Ticket_Priority Numeric(18,0),
    @Ticket_Apr_Attachment Varchar(100),
    @Ticket_Solution Varchar(200),
    @S_Emp_ID Numeric(18,0),
    @Ticket_Status Numeric(5,0),
    @User_ID Numeric(18,0),
    @Trantype char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Trantype = 'I'
		Begin
				Select @Ticket_Apr_ID = Isnull(Max(Ticket_Apr_ID),0) + 1  From T0100_Ticket_Approval  WITH (NOLOCK)
				Insert into T0100_Ticket_Approval(
					Ticket_Apr_ID,
					Ticket_App_ID,
					Cmp_ID,
					Emp_ID,
					Ticket_Type_ID,
					Ticket_Gen_Date,
					Ticket_Apr_Date,
					Ticket_Dept_ID,
					Ticket_Priority,
					Ticket_Apr_Attachment,
					Ticket_Solution,
					S_Emp_ID,
					Ticket_Status,
					Sys_Datetime,
					User_ID,
					Ticket_OnHold_Reason,
					Ticket_OnHold_Date,
					Ticket_OnHold_User
				)
				 VALUES(
					@Ticket_Apr_ID,
					@Ticket_App_ID,
					@Cmp_ID,
					@Emp_ID,
					@Ticket_Type_ID,
					@Ticket_Gen_Date,
					GETDATE(),
					@Ticket_Dept_ID,
					@Ticket_Priority,
					@Ticket_Apr_Attachment,
					@Ticket_Solution,
					@S_Emp_ID,
					(Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END),
					GETDATE(),
					@User_ID,
					@Ticket_Solution,
					GETDATE(),
					@User_ID
				)
				
				--Update T0090_Ticket_Application 
				--	SET Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END)
				--Where Ticket_App_ID = @Ticket_App_ID
				
				Update TA
					SET TA.Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END)
				From T0090_Ticket_Application TA Inner Join T0100_Ticket_Approval TTA
				ON TA.Ticket_App_ID = TTA.Ticket_App_ID
				Where TA.Ticket_App_ID = @Ticket_App_ID
		End
	Else if @Trantype = 'U'
		Begin
			if Exists(SELECT 1 From T0100_Ticket_Approval WITH (NOLOCK) Where Emp_ID = @Emp_ID and Ticket_Apr_ID = @Ticket_Apr_ID AND @Ticket_Status = 1)
				BEGIN
					UPDATE T0100_Ticket_Approval
						SET 
							Ticket_Apr_Attachment = @Ticket_Apr_Attachment,
							Ticket_Solution = @Ticket_Solution,
							S_Emp_ID = @S_Emp_ID,
							Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END),
							--Sys_Datetime = GETDATE(),
							User_ID = @User_ID
					Where Ticket_Apr_ID = @Ticket_Apr_ID and Emp_ID = @Emp_ID
					
					Update TA 
						SET TA.Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END)
					From T0090_Ticket_Application TA Inner Join T0100_Ticket_Approval TTA
					ON TA.Ticket_App_ID = TTA.Ticket_App_ID
					Where TA.Ticket_App_ID = @Ticket_App_ID
				END
			Else
				Begin
					UPDATE T0100_Ticket_Approval
					SET 
						Ticket_Apr_Attachment = @Ticket_Apr_Attachment,
						Ticket_Solution = @Ticket_Solution,
						S_Emp_ID = @S_Emp_ID,
						Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END),
						Sys_Datetime = GETDATE(),
						User_ID = @User_ID
					Where Ticket_Apr_ID = @Ticket_Apr_ID and Emp_ID = @Emp_ID
				 
					Update TA
							SET TA.Ticket_Status = (Case When @Ticket_Status = 1 THEN 'C' WHEN @Ticket_Status = 2 THEN 'H' END)
					From T0090_Ticket_Application TA Inner Join T0100_Ticket_Approval TTA
					ON TA.Ticket_App_ID = TTA.Ticket_App_ID
					Where TA.Ticket_App_ID = @Ticket_App_ID
				End
		End 
	Else if @Trantype = 'D'
		Begin
			
			Update TA
				SET TA.Ticket_Status = 'O'
			From T0090_Ticket_Application TA Inner Join T0100_Ticket_Approval TTA
			ON TA.Ticket_App_ID = TTA.Ticket_App_ID
			Where Ticket_Apr_ID = @Ticket_Apr_ID and TTA.Emp_ID = @Emp_ID
			
			Delete From T0100_Ticket_Approval Where Ticket_Apr_ID = @Ticket_Apr_ID and Emp_ID = @Emp_ID
		End
END

