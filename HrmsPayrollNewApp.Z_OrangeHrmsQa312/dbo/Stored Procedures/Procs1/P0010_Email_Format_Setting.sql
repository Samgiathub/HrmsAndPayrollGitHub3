


-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <10/07/2012>
-- Description:	<Developed for Add Mail Setting in Admin Setting>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0010_Email_Format_Setting]
(	
	@Cmp_ID				Numeric,
	@Email_Type			Varchar(50),
	@T_ID				Numeric=0,
	@Email_Title		Varchar(100),
	@Email_Signature	Varchar(Max),
	@Email_File			Varchar(Max),
	@Transtype			Varchar(1),	
	@Email_Type_ID		Numeric(18,0) = 0,
	@Notes				Varchar(Max) = '',
	@Is_Active			Numeric(18,0) = 1
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	IF @Transtype = 'I'
		BEGIN
			Select @Email_Type_ID = ISNULL(MAX(Email_Type_ID),0) + 1 from T0010_Email_Format_Setting WITH (NOLOCK)
			
			Insert into T0010_Email_Format_Setting(Email_Type_ID, Cmp_ID, Email_Type, Email_Title, Email_Signature, Email_Attachment, Notes, Is_Active,T_Id)
			Values(@Email_Type_ID, @Cmp_ID, @Email_Type, @Email_Title, @Email_Signature,@Email_File, @Notes, @Is_Active,@T_ID)
			
		END
	Else IF @Transtype = 'U'
		BEGIN
			Update T0010_Email_Format_Setting 
			Set Email_Title = @Email_Title,
			--Email_Signature = @Email_Signature,
				Email_Signature = REPLACE(@Email_Signature,
				'<p>
	&nbsp;</p>',''),					
				Email_Attachment = @Email_File,
				Is_Active = @Is_Active
			Where Cmp_ID = @Cmp_ID And Email_Type_ID = @Email_Type_ID
		END
    
END
RETURN


