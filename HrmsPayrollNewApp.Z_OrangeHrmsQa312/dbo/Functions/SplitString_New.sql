CREATE FUNCTION dbo.SplitString_New
(
    @String VARCHAR(MAX),
    @Delimiter CHAR(1)
)
RETURNS @Result TABLE (Item VARCHAR(MAX))
AS
BEGIN
    DECLARE @Pos INT
    DECLARE @Item VARCHAR(MAX)

    SET @String = LTRIM(RTRIM(@String)) + @Delimiter -- Append delimiter to handle last item
    SET @Pos = CHARINDEX(@Delimiter, @String)

    WHILE @Pos > 0
    BEGIN
        SET @Item = LTRIM(RTRIM(SUBSTRING(@String, 1, @Pos - 1)))
        INSERT INTO @Result (Item) VALUES (@Item)

        SET @String = SUBSTRING(@String, @Pos + 1, LEN(@String))
        SET @Pos = CHARINDEX(@Delimiter, @String)
    END

    RETURN
END
