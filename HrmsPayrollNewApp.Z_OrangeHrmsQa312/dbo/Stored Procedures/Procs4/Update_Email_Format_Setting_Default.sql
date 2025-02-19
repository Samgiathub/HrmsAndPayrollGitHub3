
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Update_Email_Format_Setting_Default]
	@Cmp_ID Numeric,
	@EmaiTypeName Varchar(500),
	@LoginID Numeric
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Email_Sign as varchar(max);
	Declare @Notes as varchar(Max)
	
	Set @Email_Sign = ''
	Set @Notes = ''
	
	if Not exists(Select 1 From T0010_Email_Format_Setting_Default WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName))
		BEGIN
			SELECT 0 as wcount
			return
		End
	
	Select @Email_Sign = Email_Signature,@Notes = Notes From T0010_Email_Format_Setting_Default WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName)
	
	if exists(Select 1 From T0010_Email_Format_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName))
		BEGIN

			declare @Email_Type_ID1 as integer
			select @Email_Type_ID1 = isnull(MAX(Email_Type_ID),0) +1 from T0010_Email_Format_Setting_History WITH (NOLOCK)

			
			Insert into T0010_Email_Format_Setting_History
			SELECT @Email_Type_ID1,Cmp_ID,Email_Type,Email_Title,Email_Signature,Email_Attachment,Notes,@LoginID,GETDATE()
			From T0010_Email_Format_Setting_Default WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName)
			
			Update T0010_Email_Format_Setting
				Set 
					Email_Signature = @Email_Sign,
					Notes = @Notes
			Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName)
		End
	Else
		Begin
			Declare @Email_Type_ID Numeric
			Set @Email_Type_ID = 0
			select @Email_Type_ID = isnull(MAX(Email_Type_ID),0) +1 from T0010_Email_Format_Setting_History WITH (NOLOCK)
			
			Insert INTO T0010_Email_Format_Setting
			SELECT @Email_Type_ID,Cmp_ID,Email_Type,Email_Title,Email_Signature,Email_Attachment,Notes,Is_Active,Module_Name 
			FROM T0010_Email_Format_Setting_Default WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Upper(Email_Type) = UPPER(@EmaiTypeName)
			
		End
	Select 1 as wcount
    
END
