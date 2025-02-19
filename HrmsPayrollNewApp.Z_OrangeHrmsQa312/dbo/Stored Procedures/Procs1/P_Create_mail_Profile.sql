


--Created by rohit For create Mail profile Account from page.
-- Created ON 28062016
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[P_Create_mail_Profile]
	@profile_name varchar(500),
	@description varchar(max),
	@Email_Address varchar(500),
	@mailserver_name varchar(500),
	@port numeric(18,0),
	@enable_ssl tinyint,
	@username varchar(500),
	@password varchar(500),
	@display_name varchar(500),
	@cmp_id numeric(18,0),
	@link varchar(max),
	@trans_Type char(1)='I'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
BEGIN Try

	set @trans_Type = 'I'

	declare @DB_Mail_Profile_Id as numeric(18,0)
	if  exists(SELECT account_id FROM msdb.dbo.sysmail_account WITH (NOLOCK) WHERE name=@profile_name)
	begin
		set @trans_Type = 'U'
	end

	select @trans_Type,@DB_Mail_Profile_Id
	if (@trans_Type ='I')
	begin
		--Creating a Profile
		EXECUTE msdb.dbo.sysmail_add_profile_sp
		@profile_name = @profile_name,
		@description = @description ;

		-- Create a Mail account for gmail. We have to use our company mail account.
		EXECUTE msdb.dbo.sysmail_add_account_sp
		@account_name = @profile_name,
		@email_address = @Email_Address,
		@mailserver_name = @mailserver_name,
		@port=@port,
		@enable_ssl=@enable_ssl,
		@username=@username ,
		@password=@password,
		@display_name = @display_name

		-- Adding the account to the profile
		EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
		@profile_name = @profile_name,
		@account_name = @profile_name,
		@sequence_number =1 ;

		-- Granting access to the profile to the DatabaseMailUserRole of MSDB
		EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
		@profile_name = @profile_name,
		@principal_id = 0,
		@is_default = 1 ;

		select @DB_Mail_Profile_Id = isnull(max(DB_Mail_Profile_Id),0) + 1 from t9999_Reminder_Mail_Profile WITH (NOLOCK)

		insert into t9999_Reminder_Mail_Profile
		(DB_Mail_Profile_Id,DB_Mail_Profile_Name,cmp_id,Email_Id,Password,Remark,Server_link,DB_Backup_Path)
		values(@DB_Mail_Profile_Id ,@profile_name,@cmp_id,@Email_Address,NULL,'',@link,	NULL)

	end
	else if(@trans_Type='U')
	begin
		EXECUTE msdb.dbo.sysmail_update_account_sp
			@account_name = @profile_name
			,@description = @description
			,@email_address = @Email_Address
			,@mailserver_name = @mailserver_name
			,@port=@port
			,@enable_ssl=@enable_ssl
			,@username=@username 
			,@password=@password


		update t9999_Reminder_Mail_Profile 
		set Email_Id = @Email_Address,Server_link = @link
		where DB_Mail_Profile_Name= @profile_name 
		and cmp_id=@cmp_id

		
	end 

END Try
Begin Catch
		
End Catch


return
