Create FUNCTION fnGetFileName
(
    @fullpath nvarchar(260)
) 
RETURNS nvarchar(260)
AS
BEGIN
    IF(CHARINDEX('\', @fullpath) > 0)
       SELECT @fullpath = RIGHT(@fullpath, CHARINDEX('\', REVERSE(@fullpath)) -1)
       RETURN @fullpath
END