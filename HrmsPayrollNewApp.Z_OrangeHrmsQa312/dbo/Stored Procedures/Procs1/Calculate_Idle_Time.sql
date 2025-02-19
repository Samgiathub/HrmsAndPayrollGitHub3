create PROCEDURE [dbo].[Calculate_Idle_Time]
    @Emp_ID int,
    @Cmp_ID int,
    @Date date
AS 
BEGIN
    SET NOCOUNT ON;

    WITH GroupedGeoLocation AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY Latitude, Longitude ORDER BY [Date]) AS RowNumber
        FROM Tbl_GeoLocationTracking
        WHERE CONVERT(date, [Date]) = @Date 
              AND CmpID = @Cmp_ID 
              AND Empid = @Emp_ID
    )
    SELECT 
        Latitude,
        Longitude,
        DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) AS IdleTimeInMinutes
    FROM GroupedGeoLocation
    GROUP BY 
        Latitude,
        Longitude,
        DATEADD(minute, -RowNumber, [Date]);
END;
