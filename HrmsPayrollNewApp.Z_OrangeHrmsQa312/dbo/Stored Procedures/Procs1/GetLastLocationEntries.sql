CREATE PROCEDURE GetLastLocationEntries
    @Emp_ID INT,
    @Cmp_ID INT,
    @Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    WITH LocationGroups AS (
        SELECT 
            Date,
            Latitude,
            Longitude,
            Address_location,
            ROW_NUMBER() OVER (PARTITION BY Latitude, Longitude ORDER BY Date DESC) AS RowNum
        FROM 
            Tbl_GeoLocationTracking
        WHERE 
            EmpID = @Emp_ID 
            AND CmpID = @Cmp_ID 
            AND CONVERT(date, Date, 103) = @Date
    )
    SELECT 
        Date,
        Latitude,
        Longitude,
        Address_location
    FROM 
        LocationGroups
    WHERE 
        RowNum = 1; -- Selects the last entry for each distinct latitude and longitude pair
END;
