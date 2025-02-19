


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_EmailNotificaiton_Config]
	  @Email_NTF_ID	numeric(18, 0) output
	 ,@Email_Type_Name	varchar(100)
	 ,@Cmp_Id			numeric(10)
	 ,@Email_NTF_Sent	numeric(1,0)
	 ,@Email_Def_ID		numeric(18,0)	 
	 ,@tran_type		char
	 ,@To_Manager		numeric(1,0) = 0 
	 ,@To_Hr			numeric(1,0) = 0 
	 ,@To_Account		numeric(1,0) = 0 
	 ,@Other_Email		varchar(200) = ''
	 ,@Is_Manager_CC	tinyint = 0
	 ,@Is_HR_CC			TinyInt = 0
	 ,@Is_Account_CC	TinyInt = 0
	 ,@Other_Email_Bcc		varchar(200) = ''  --Added By Jimit 14052019
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @tran_type ='I' 
		begin
			if Exists (select Email_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Email_Type_Name=@Email_Type_Name And Cmp_ID=@Cmp_ID)
				Begin
					set @Email_NTF_ID=0
					return
				End
			
		    	select @Email_NTF_ID = isnull(max(Email_NTF_ID),0) + 1 from T0040_Email_Notification_Config WITH (NOLOCK)
						
				insert into T0040_Email_Notification_Config(Email_NTF_ID,Email_Type_Name,Cmp_Id,Email_NTF_Sent,Email_NTF_Def_ID,To_Manager,To_Hr,To_Account,Other_Email,Is_Manager_CC,Is_HR_CC,Is_Account_CC,other_Email_Bcc) 
				values(@Email_NTF_ID,@Email_Type_Name,@Cmp_Id,@Email_NTF_Sent,@Email_Def_ID,@To_Manager,@To_Hr,@To_Account,@Other_Email,@Is_Manager_CC,@Is_HR_CC,@Is_Account_CC,@Other_Email_Bcc)

		end 
	else if @tran_type ='U' 
		begin
		
			if Exists (select Email_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Email_Type_Name=@Email_Type_Name And Cmp_ID=@Cmp_ID And Email_NTF_ID <> @Email_NTF_ID)
				Begin
					set @Email_NTF_ID=0
					return
				End
			select @Email_NTF_ID as Email_NTF_ID
				Update T0040_Email_Notification_Config 
				Set 
				Email_NTF_Sent=@Email_NTF_Sent
				,To_Manager = @To_Manager
				,To_Hr =@To_Hr
				,To_Account =@To_Account
				,Other_Email =@Other_Email
				,Is_Manager_CC = @Is_Manager_CC
				,Is_HR_CC = @Is_HR_CC
				,Is_Account_CC = @Is_Account_CC
				,Other_Email_Bcc = @Other_Email_Bcc
				where Email_NTF_ID = @Email_NTF_ID 
		end	
	else if upper(@tran_type) ='D'
		Begin
			delete  from T0040_Email_Notification_Config where Email_NTF_ID=@Email_NTF_ID 
		end
			
	RETURN




