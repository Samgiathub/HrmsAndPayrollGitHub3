


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 08-10-2017 
-- Description:	For Ticket Application
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_Ticket_Application]
	@Ticket_App_ID Numeric(18,0) Output,
	@Cmp_ID Numeric(18,0),
    @Emp_ID Numeric(18,0),
    @Ticket_Type_ID Numeric(18,0),
    @Ticket_Gen_Date Datetime,
    @Ticket_Dept_ID Numeric(18,0),
    @Ticket_Priority Varchar(50),
    @Ticket_Attachment Varchar(100),
    @Ticket_Description Varchar(500),
    @User_ID Numeric(18,0),
    @Trantype char(1),
    @Is_Candidate int = 0,
	@SendTo Varchar(200) = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if @Trantype = 'I'
		Begin
			
			Declare @Escalation_Hours Numeric(18,2)
			Set @Escalation_Hours = 0
			If Exists(Select 1 From T0040_Ticket_Priority WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Tran_ID = @Ticket_Priority)
				BEGIN
					Select @Escalation_Hours = Case When Hours_Limit <> '' THEN  Cast(Isnull(Replace(Hours_Limit,':','.'),0) AS numeric(18,2)) ELSE 0 END From T0040_Ticket_Priority WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Tran_ID = @Ticket_Priority
				END
		
			if Exists(SELECT 1 FROM T0090_Ticket_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ticket_Type_ID = @Ticket_Type_ID and
			
			convert(date,Ticket_Gen_Date,103)=convert(date,@Ticket_Gen_Date,103) and Ticket_Dept_ID=@Ticket_Dept_ID or Ticket_Description=@Ticket_Description ) ---added by aswini 20/12/2023
			--AND Ticket_Status = 'O')--commented aswini 20/12/2023
				BEGIN
					raiserror('@@Same Ticket Type Application is Exists.@@',16,2)
					return
				End
			
			Select @Ticket_App_ID = Isnull(Max(Ticket_App_ID),0) + 1 From T0090_Ticket_Application WITH (NOLOCK)
			Insert into T0090_Ticket_Application(
													Ticket_App_ID,
													Cmp_ID,
													Emp_ID,
													Ticket_Type_ID,
													Ticket_Gen_Date,
													Ticket_Dept_ID,
													Ticket_Priority,
													Ticket_Attachment,
													Ticket_Description,
													Ticket_Status,
													Sys_Datetime,
													User_ID,
													Is_Candidate,
													Escalation_Hours,
													SendTo
												)
										 VALUES(
													@Ticket_App_ID,
													@Cmp_ID,
													@Emp_ID,
													@Ticket_Type_ID,
													@Ticket_Gen_Date,
													@Ticket_Dept_ID,
													@Ticket_Priority,
													@Ticket_Attachment,
													@Ticket_Description,
													'O',
													GETDATE(),
													@User_ID,
													@Is_Candidate,
													@Escalation_Hours,
													@SendTo
												)
		End
	Else if @Trantype = 'D'
		Begin
			if Exists(SELECT 1 FROM T0100_Ticket_Approval WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ticket_App_ID = @Ticket_App_ID )
				BEGIN
					raiserror('@@Ticket Type Application reference is Exists.@@',16,2)
					return
				END
			Delete From T0090_Ticket_Application Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
		End
	Else if @Trantype = 'U'
		Begin
			if Exists(SELECT 1 FROM T0090_Ticket_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ticket_Type_ID = @Ticket_Type_ID AND Ticket_Status = 'O' AND Ticket_App_ID <> @Ticket_App_ID)
				BEGIN
					raiserror('@@Same Ticket Type Application is Exists.@@',16,2)
					return
				End
				
			Update T0090_Ticket_Application
				SET
					Ticket_Type_ID = @Ticket_Type_ID,
					Ticket_Gen_Date = @Ticket_Gen_Date,
					Ticket_Dept_ID = @Ticket_Dept_ID,
					Ticket_Priority = @Ticket_Priority,
					Ticket_Attachment = @Ticket_Attachment,
					Ticket_Description = @Ticket_Description,
					Ticket_Status = 'O',
					Is_Candidate = @Is_Candidate,
					SendTo = @SendTo
			Where Ticket_App_ID = @Ticket_App_ID and Emp_ID = @Emp_ID
		End
END


