
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[sp_SMTPMail]

	@SenderName varchar(100),
	@SenderAddress varchar(100),
	@RecipientName varchar(100),
	@RecipientAddress varchar(100),
	@Subject varchar(200),
	@Body varchar(8000),
	@MailServer varchar(100) = 'localhost'

	AS	
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON


	declare @oMail int --Object reference
	declare @resultcode int
	
	EXEC @resultcode = sp_OAcreate 'SMTPsvg.Mailer', @oMail OUT

	if @resultcode = 0
	BEGIN
		EXEC @resultcode = sp_OASetProperty @oMail, 'RemoteHost',  @mailserver
		EXEC @resultcode = sp_OASetProperty @oMail, 'FromName', @SenderName
		EXEC @resultcode = sp_OASetProperty @oMail, 'FromAddress',  @SenderAddress

		EXEC @resultcode = sp_OAMethod @oMail, 'AddRecipient', NULL, @RecipientName,  @RecipientAddress

		EXEC @resultcode = sp_OASetProperty @oMail, 'Subject', @Subject
		EXEC @resultcode = sp_OASetProperty @oMail, 'BodyText', @Body


		EXEC @resultcode = sp_OAMethod @oMail, 'SendMail', NULL

		EXEC sp_OADestroy @oMail
	END	

