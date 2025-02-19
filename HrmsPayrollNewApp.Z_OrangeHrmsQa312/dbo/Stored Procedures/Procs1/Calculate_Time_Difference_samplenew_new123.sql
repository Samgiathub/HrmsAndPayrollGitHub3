create PROCEDURE [dbo].[Calculate_Time_Difference_samplenew_new123]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Latitude,
        Longitude,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) < 10 THEN 'Yes' ELSE 'No' END AS SpentLessThan10Mins,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) BETWEEN 10 AND 29 THEN 'Yes' ELSE 'No' END AS SpentBetween10And29Mins,
        CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) >= 30 THEN 'Yes' ELSE 'No' END AS Spent30MinsOrMore
    FROM 
        Tbl_GeoLocationTracking
    WHERE 
        CONVERT(date, Date, 103) = @Date 
        AND CmpID = @Cmp_ID 
        AND Empid = @Emp_ID
    GROUP BY 
        Latitude,
        Longitude;
END;
