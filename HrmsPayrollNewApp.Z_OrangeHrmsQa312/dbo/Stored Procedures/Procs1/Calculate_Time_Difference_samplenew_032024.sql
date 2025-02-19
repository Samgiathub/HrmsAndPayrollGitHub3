create PROCEDURE [dbo].[Calculate_Time_Difference_samplenew_032024]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime,
    @Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @TimeDifference int;
    DECLARE @Latitude decimal(9,6);
    DECLARE @Longitude decimal(9,6);
    DECLARE @Count INT;
    DECLARE @Index INT;

    DECLARE @Locations TABLE
    (
        Latitude decimal(9,6),
        Longitude decimal(9,6)
    );

    -- Insert all latitude and longitude pairs into @Locations table
    INSERT INTO @Locations (Latitude, Longitude)
    SELECT Latitude, Longitude
    FROM Tbl_GeoLocationTracking
    WHERE CONVERT(date, Date, 103) = @Date 
          AND CmpID = @Cmp_ID 
          AND Empid = @Emp_ID;

    -- Loop through each distinct pair of latitude and longitude
    SET @Index = 1;
    SET @Count = (SELECT COUNT(*) FROM @Locations);

    WHILE @Index <= @Count
    BEGIN
        SELECT TOP 1 @Latitude = Latitude, @Longitude = Longitude
        FROM @Locations;

        SELECT @TimeDifference = DATEDIFF(MINUTE, MIN(Date), MAX(Date))
        FROM Tbl_GeoLocationTracking
        WHERE CONVERT(date, Date, 103) = @Date 
              AND CmpID = @Cmp_ID 
              AND Empid = @Emp_ID
              AND Latitude = @Latitude
              AND Longitude = @Longitude;

        IF @TimeDifference > 30
        BEGIN
            SET @Result = 'Spent Time is more than 30 minutes for coordinates (' + CONVERT(VARCHAR, @Latitude) + ', ' + CONVERT(VARCHAR, @Longitude) + ')';
            SELECT @Result as Msg;
        END
        ELSE IF @TimeDifference > 10
        BEGIN
            SET @Result = 'Spent Time is more than 10 minutes for coordinates (' + CONVERT(VARCHAR, @Latitude) + ', ' + CONVERT(VARCHAR, @Longitude) + ')';
            SELECT @Result as Msg;
        END
        ELSE
        BEGIN
            SET @Result = 'Spent Time is less than 10 minutes for coordinates (' + CONVERT(VARCHAR, @Latitude) + ', ' + CONVERT(VARCHAR, @Longitude) + ')';
            SELECT @Result as Msg;
        END;

        DELETE FROM @Locations WHERE Latitude = @Latitude AND Longitude = @Longitude;
        SET @Index = @Index + 1;
    END;
END;
