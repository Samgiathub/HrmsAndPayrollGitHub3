CREATE FUNCTION dbo.fn_SplitString
(
    @InputString NVARCHAR(MAX),    -- The input comma-separated string
    @Delimiter CHAR(1)            -- The delimiter to split by (e.g., ',' for CSV)
)
RETURNS @OutputTable TABLE (Value NVARCHAR(MAX))  -- Return table with each value from the string
AS
BEGIN
    WITH SplitCTE AS (
        SELECT 
            LEFT(@InputString, CHARINDEX(@Delimiter, @InputString) - 1) AS Value,
            RIGHT(@InputString, LEN(@InputString) - CHARINDEX(@Delimiter, @InputString)) AS RemainingString
        WHERE CHARINDEX(@Delimiter, @InputString) > 0
        UNION ALL
        SELECT
            LEFT(RemainingString, CHARINDEX(@Delimiter, RemainingString) - 1),
            RIGHT(RemainingString, LEN(RemainingString) - CHARINDEX(@Delimiter, RemainingString))
        FROM SplitCTE
        WHERE CHARINDEX(@Delimiter, RemainingString) > 0
        UNION ALL
        SELECT RemainingString, NULL
        FROM SplitCTE
        WHERE RemainingString IS NOT NULL
    )
    -- Insert results into the output table
    INSERT INTO @OutputTable (Value)
    SELECT Value
    FROM SplitCTE
    WHERE Value IS NOT NULL

    RETURN
END
