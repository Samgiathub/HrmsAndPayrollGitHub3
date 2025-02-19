Create FUNCTION GetFileName
(
 @fullpath nvarchar(260)
) 
RETURNS nvarchar(260)
AS
BEGIN
DECLARE @charIndexResult int
SET @charIndexResult = CHARINDEX('\', REVERSE(@fullpath))

IF @charIndexResult = 0
    RETURN NULL 

RETURN RIGHT(@fullpath, @charIndexResult -1)
END
