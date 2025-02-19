-- select dbo.fnc_GetChildForms(20345)
-- drop function dbo.fnc_GetChildForms
CREATE FUNCTION [dbo].[fnc_GetChildForms](@FormId INT, @rVirtualPath VARCHAR(100))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SELECT @lResult = @lResult + '<li><a href="' + @rVirtualPath + ISNULL(Form_url,'') + '">' + ISNULL(Form_Image_url,'') + '<span>' + ISNULL(Form_Name,'') + '</span></a></li>'
	FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @FormId

	RETURN @lResult
END