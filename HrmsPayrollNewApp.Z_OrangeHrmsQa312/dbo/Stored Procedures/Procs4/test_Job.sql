
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[test_Job]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Count Numeric(18,0)
	Select @Count = Count(*) From T0080_Emp_Master WITH (NOLOCK) Where Cmp_ID = 1491
	if @Count = 0
		Begin
		
		RAISERROR('test',
             16,
             1 )
			 END

	if @Count > 0 
		Begin
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Acer-7', @recipients = 'nilesh.p@orangewebtech.com', @subject = 'Auto Credit Comp-off Leave Balance For Same Date Holiday and Weekoff', @body = 'test Mail By Nilesh', @body_format = 'HTML',@copy_recipients = '',@blind_copy_recipients = ''
		End

END

