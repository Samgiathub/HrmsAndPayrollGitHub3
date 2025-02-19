CREATE PROCEDURE [dbo].[Calculate_Time_Difference2]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime,
    @Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @Latitude DECIMAL(9,6);
    DECLARE @Longitude DECIMAL(9,6);
    DECLARE @MinDate DATETIME;
    DECLARE @MaxDate DATETIME;
    DECLARE @TimeDifference INT;

    DECLARE location_cursor CURSOR FOR
    SELECT DISTINCT latitude, longitude
    FROM Tbl_GeoLocationTracking
    WHERE CONVERT(date, Date, 103) = @Date
          AND CmpID = @Cmp_ID 
          AND Empid = @Emp_ID;

    OPEN location_cursor;

    FETCH NEXT FROM location_cursor INTO @Latitude, @Longitude;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @MinDate = MIN(Date), @MaxDate = MAX(Date)
        FROM Tbl_GeoLocationTracking
        WHERE latitude = @Latitude
              AND longitude = @Longitude
              AND CONVERT(date, Date, 103) = @Date
              AND CmpID = @Cmp_ID 
              AND Empid = @Emp_ID;

        SET @TimeDifference = DATEDIFF(MINUTE, @MinDate, @MaxDate);

        

        IF @TimeDifference > 10
        BEGIN
            SET @Result = 'Spent Time is more than 10 minutes';
            SELECT @Result as Msg;
			PRINT @TimeDifference;
        END
        ELSE
        BEGIN
            SET @Result = 'Spent Time is less than 10 minutes';
            SELECT @Result as Msg;
			PRINT @TimeDifference;
        END;

        IF @TimeDifference >= 30
        BEGIN
            SET @Result = 'Spent Time is more than 30 minutes';
            SELECT @Result as Msg;
			PRINT @TimeDifference;
        END;

        FETCH NEXT FROM location_cursor INTO @Latitude, @Longitude;
    END;
	
    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
--exec Calculate_Time_Difference2 @Emp_ID=28199, @Cmp_id=187,@Date='2024-04-04',@Result=''