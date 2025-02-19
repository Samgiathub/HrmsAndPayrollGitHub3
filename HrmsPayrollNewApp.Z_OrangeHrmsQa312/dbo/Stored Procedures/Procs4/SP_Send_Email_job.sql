

---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Send_Email_job]
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	Declare @Email_logs_id Numeric(18,0)
	Declare @To_Email varchar(500)
	Declare @cc_Email varchar(500)
	Declare @To_Email_1 varchar(500)
	Declare @sub varchar(500)
	Declare @Body_Email varchar(max)
	Declare @Body_Email_1 varchar(max)
	Declare @cmp_id Numeric(18,0)
	
	Declare Cur_Email Cursor For 
	Select Email_logs_id,To_Email,cc_Email,sub,Body_Email,cmp_id From Email_logs where Send_Mail_Job = 1 and Email_Send_Flag = 0 
	Open Cur_Email
	fetch next from Cur_Email into @Email_logs_id,@To_Email,@cc_Email,@sub,@Body_Email,@cmp_id
    while @@fetch_status = 0
		Begin
			Declare @profile as varchar(50)
			set @profile = ''
		       					  
			select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @cmp_id
		       					  
			if isnull(@profile,'') = ''
       			begin
       				select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       			end
		    
			Set @To_Email_1 = REPLACE(@To_Email,',',';')  
		    Set @Body_Email_1 =  Replace(@Body_Email,'Leave Application Job','Leave Application')	
		              			              
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @To_Email, @subject = @sub, @body = @Body_Email, @body_format = 'HTML',@copy_recipients = @cc_Email
			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @To_Email_1, @subject = @sub, @body = @Body_Email_1, @body_format = 'HTML',@copy_recipients = @cc_Email
			
			update Email_logs set Email_Send_Flag = 1,Email_Send_Date = GETDATE() where Email_logs_id = @Email_logs_id
			
			fetch next from Cur_Email into @Email_logs_id,@To_Email,@cc_Email,@sub,@Body_Email,@cmp_id
		End 
   	close Cur_Email                    
	deallocate Cur_Email
END

