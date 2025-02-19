CREATE PROCEDURE [dbo].[Calculate_Time_Difference_samplenew_new11]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @TempTable TABLE
    (
        Latitude decimal(9,6),
        Longitude decimal(9,6),
        TimeDifferenceLessThan10 int,
        TimeDifference10To29 int,
        TimeDifference30OrMore int
    );

    INSERT INTO @TempTable (Latitude, Longitude, TimeDifferenceLessThan10, TimeDifference10To29, TimeDifference30OrMore)
    SELECT 
        Latitude,
        Longitude,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) < 10 THEN 1 ELSE 0 END AS TimeDifferenceLessThan10,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) BETWEEN 10 AND 29 THEN 1 ELSE 0 END AS TimeDifference10To29,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) >= 30 THEN 1 ELSE 0 END AS TimeDifference30OrMore
    FROM 
        Tbl_GeoLocationTracking
    WHERE 
        CONVERT(date, Date, 103) = @Date 
        AND CmpID = @Cmp_ID 
        AND Empid = @Emp_ID
    GROUP BY 
        Latitude,
        Longitude;

    SELECT 
        Latitude,
        Longitude,
        CASE WHEN TimeDifferenceLessThan10 = 1 THEN 'Yes' ELSE 'No' END AS SpentLessThan10Mins,
        CASE WHEN TimeDifference10To29 = 1 THEN 'Yes' ELSE 'No' END AS Spentmorethan10Mins,
        CASE WHEN TimeDifference30OrMore = 1 THEN 'Yes' ELSE 'No' END AS Spentmorethan30Mins
    FROM 
        @TempTable;
END;
--exec Calculate_Time_Difference_samplenew_new11 @Emp_ID=28201, @Cmp_id=187,@Date='2024-04-03'