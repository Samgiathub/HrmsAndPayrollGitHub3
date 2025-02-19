

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 08-Dec-2017
-- Description:	To get the property defined in email template
-- =============================================
CREATE FUNCTION [DBO].[fn_getEmailTemplateProperty] 
(
	-- Add the parameters for the function here
	@Template		Varchar(Max),
	@PropertyName	VARCHAR(256)
)
RETURNS VARCHAR(256)
AS
BEGIN	
	IF CHARINDEX('@',@PropertyName) <> 1
		SET @PropertyName = '@' + @PropertyName 
	DECLARE @PropertyValue VARCHAR(256)
	SET @PropertyValue = ''
	IF CHARINDEX(@PropertyName,@Template) > 0
		BEGIN 
			SET @PropertyValue  =  substring(@Template, CHARINDEX(@PropertyName, @Template), LEN(@Template))					
			SET @PropertyValue  =  SUBSTRING(@PropertyValue, CHARINDEX(':',@PropertyValue)+1, LEN(@PropertyValue))
			SET @PropertyValue  =  SUBSTRING(@PropertyValue, 0, CHARINDEX(';',@PropertyValue))			
		END

	-- Return the result of the function
	
	RETURN @PropertyValue

END

