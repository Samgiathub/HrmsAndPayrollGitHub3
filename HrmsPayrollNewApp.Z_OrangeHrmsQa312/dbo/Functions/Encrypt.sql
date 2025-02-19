



CREATE FUNCTION DBO.Encrypt (@STR NVARCHAR(4000))
Returns varbinary(8000)
AS
  BEGIN
    DECLARE @res varbinary(8000)
    SET @res = ENCRYPTBYPASSPHRASE('ORANGE HRMS',@str)
    RETURN (@res)
  END




