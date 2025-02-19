
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_GET_EMAIL_FORMAT]
(
@Cmp_Id AS NUMERIC,
@Email_Type as varchar(50),
@company_Signature as numeric
)
RETURNS NVARCHAR(Max)
AS
BEGIN

	
	DECLARE @Email_Format AS NVARCHAR(Max)
	
	if (@company_Signature = 0)
		select @Email_Format=replace(Email_Signature,'Ultimatix™ Powered By: Orange Technolab P. Ltd.','') From T0010_Email_Format_Setting WITH (NOLOCK) where cmp_id=@cmp_id and Email_Type=@Email_Type  
	ELSE
		select @Email_Format=Email_Signature From T0010_Email_Format_Setting WITH (NOLOCK) where cmp_id=@cmp_id and Email_Type=@Email_Type
		
	RETURN @Email_Format	
END




