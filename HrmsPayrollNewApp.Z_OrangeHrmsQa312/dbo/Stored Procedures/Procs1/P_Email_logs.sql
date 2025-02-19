

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Email_logs]
		 @Email_Logs_ID		as numeric output
		,@Cmp_ID			as Numeric 
		,@Module_Name		as varchar(50) 
		,@To_Email			as varchar(Max) 
		,@cc_Email			as varchar(Max)
		,@subject			as varchar(50)
		,@Body_Email	    as varchar(max)
		,@Email_Error		as varchar(max)
		,@Email_Status		as integer
		,@Attach_Path		as varchar(max)
		,@Form_Name			as varchar(max) = ''
		,@Send_Mail_Job		as Integer = 0
		,@Email_Send_Flag	as Integer = 0
		,@Email_Send_Date   as Datetime = NULL
		,@tran_type			as varchar(1)
		
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @Email_Logs_ID = 0
			set @Email_Logs_ID =null
		
		if @Email_Send_Date = ''
			Set @Email_Send_Date = Null
		
		If @tran_type ='I' 
			begin
				if exists(select Email_logs_id from Email_logs WITH (NOLOCK) where Email_Logs_ID = @Email_Logs_ID)
					begin
						return 0
					end								
				select @Email_Logs_ID = isnull(max(Email_logs_id),0) + 1 from Email_logs WITH (NOLOCK)
			
				INSERT INTO Email_logs
				                      (Email_logs_id, Cmp_ID,Module_Name, To_Email, cc_Email,sub,Body_Email,Error_Email,Status,Gen_Date,Attach_Path,Form_Name,Send_Mail_Job,Email_Send_Flag,Email_Send_Date)
				VALUES     (@Email_Logs_ID, @Cmp_ID, @Module_Name, @To_Email,@cc_Email,@subject,@Body_Email,@Email_Error,@Email_Status,GETDATE(),@attach_Path,@Form_Name,@Send_Mail_Job,@Email_Send_Flag,@Email_Send_Date)
			
			end 
	Else If @tran_type ='U' 
				begin
				
				if not exists( select Email_logs_id  from Email_logs WITH (NOLOCK) Where  Email_logs_id = @Email_Logs_ID )
					begin
						return 0
					end		
					
											
					UPDATE    Email_logs
					SET       status =@Email_Status
					WHERE     Email_logs_id = @Email_Logs_ID 
					
				end
					
	Else If @tran_type ='D'
			Begin
				delete  from Email_logs where Email_logs_id =@Email_Logs_ID 
			End		

	RETURN




