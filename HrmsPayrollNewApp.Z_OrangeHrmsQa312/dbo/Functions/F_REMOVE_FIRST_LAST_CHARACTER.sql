




CREATE FUNCTION [DBO].[F_REMOVE_FIRST_LAST_CHARACTER]
(
@String AS VARCHAR(100)
)
RETURNS VARCHAR(100)
AS
BEGIN
	
		-- Chop off the end character
		SET @String = LEFT(@String, LEN(@String) - 1)
		SET @String = right(@String, LEN(@String) - 1)

	RETURN @String	
END




