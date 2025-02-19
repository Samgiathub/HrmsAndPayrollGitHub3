CREATE PROCEDURE [dbo].[Calculate_Idle_Time_Categories]
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
		DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) AS IdleTimeInMinutes,
        CASE 
            WHEN DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) < 10 THEN 'Less than 10 mins'
            WHEN DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) >= 10 AND DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) < 30 THEN 'Between 10 and 29 mins'
            WHEN DATEDIFF(MINUTE, MIN([Date]), MAX([Date])) >= 30 THEN 'More than 30 mins'
            ELSE 'Unknown'
        END AS IdleTimeCategory
    FROM GroupedGeoLocation
    GROUP BY 
        Latitude,
        Longitude,
        DATEADD(minute, -RowNumber, [Date]);
END;
--exec Calculate_Idle_Time_Categories @Emp_ID=28199, @Cmp_id=187,@Date='2024-04-03'