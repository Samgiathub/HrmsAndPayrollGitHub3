

-- created by rohit for get last character index from string on 29122016
CREATE FUNCTION GetLastCharIndex(@S NVARCHAR(MAX), @CHAR NVARCHAR(200)) RETURNS INT
as
begin
 
 DECLARE  @lastIndex int
 DECLARE  @nOccurance int
 DECLARE @searchExpression NVARCHAR(max)
 SET @nOccurance = len(@s)
 SET @lastIndex = 0
 SET @searchExpression = @s
 
 while @nOccurance > 0
 BEGIN 
	SELECT @nOccurance = charIndex(@char, @searchExpression)
	IF (@nOccurance > 0)
	BEGIN
		SET @lastIndex = @lastIndex + @nOccurance
		SET @searchExpression = substring(@searchExpression, @nOccurance + 1, len(@searchExpression))
	END
 END
 
	
 return @lastIndex
 
end

