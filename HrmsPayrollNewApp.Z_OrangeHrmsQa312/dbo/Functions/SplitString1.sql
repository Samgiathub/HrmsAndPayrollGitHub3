CREATE FUNCTION dbo.SplitString1 (@InputString NVARCHAR(MAX), @Delimiter CHAR(1))
RETURNS @OutputTable TABLE (Value NVARCHAR(MAX), RowNum INT)
AS
BEGIN
    DECLARE @XML XML = '<root><r>' + REPLACE(@InputString, @Delimiter, '</r><r>') + '</r></root>';
    
    INSERT INTO @OutputTable (Value, RowNum)
    SELECT t.value('.', 'NVARCHAR(MAX)'), ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM @XML.nodes('/root/r') AS x(t);
    
    RETURN;
END;