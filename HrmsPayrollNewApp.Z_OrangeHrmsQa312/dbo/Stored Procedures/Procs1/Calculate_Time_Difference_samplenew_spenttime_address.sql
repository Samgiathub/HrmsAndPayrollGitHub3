Create PROCEDURE [dbo].[Calculate_Time_Difference_samplenew_spenttime_address]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime
AS 
BEGIN
    SET NOCOUNT ON;




WITH AddressGroups AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY Date) - 
           ROW_NUMBER() OVER (PARTITION BY EmpID, Address_location ORDER BY Date) AS Grp
    FROM Tbl_GeoLocationTracking
    WHERE CONVERT(date, Date, 103) = @Date
          AND CmpID = @Cmp_ID
          AND Empid = @Emp_ID
)

SELECT 
    MAX(Address_location) AS Address,
    MAX(Latitude) AS Latitude,
    MAX(Longitude) AS Longitude,
    CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) < 10 THEN 1 ELSE 0 END AS TimeDifferenceLessThan10,
    CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) BETWEEN 10 AND 29 THEN 1 ELSE 0 END AS TimeDifference10To29,
    CASE WHEN DATEDIFF(MINUTE, MIN(Date), MAX(Date)) >= 30 THEN 1 ELSE 0 END AS TimeDifference30OrMore
FROM AddressGroups
GROUP BY Grp;
end