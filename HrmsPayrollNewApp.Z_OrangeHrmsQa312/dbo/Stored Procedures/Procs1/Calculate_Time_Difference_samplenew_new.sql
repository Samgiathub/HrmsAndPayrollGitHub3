create PROCEDURE [dbo].[Calculate_Time_Difference_samplenew_new]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime,
    @Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @TempTable TABLE
    (
        Latitude decimal(9,6),
        Longitude decimal(9,6),
        TimeDifference10 int,
        TimeDifference30 int
    );

    INSERT INTO @TempTable (Latitude, Longitude, TimeDifference10, TimeDifference30)
    SELECT 
        Latitude,
        Longitude,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) > 10 THEN 1 ELSE 0 END AS TimeDifference10,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) > 30 THEN 1 ELSE 0 END AS TimeDifference30
    FROM 
        Tbl_GeoLocationTracking
    WHERE 
        CONVERT(date, Date, 103) = @Date 
        AND CmpID = @Cmp_ID 
        AND Empid = @Emp_ID
    GROUP BY 
        Latitude,
        Longitude;

    DECLARE @Msg varchar(max) = '';

    SELECT 
        @Msg = @Msg + 'Latitude: ' + CONVERT(varchar, Latitude) + ', Longitude: ' + CONVERT(varchar, Longitude) + 
        ', Spent more than 10 mins: ' + CASE WHEN TimeDifference10 = 1 THEN 'Yes' ELSE 'No' END + 
        ', Spent more than 30 mins: ' + CASE WHEN TimeDifference30 = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    FROM 
        @TempTable;

    SET @Result = @Msg;
    SELECT @Result as Msg;
END;
