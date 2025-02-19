CREATE PROCEDURE [dbo].[SP_GeoLocationTracing_Spenttime_sample]
    @Emp_ID NUMERIC(18,0),  
    @Cmp_ID NUMERIC(18,0), 
    @Date datetime,
    @Latitude VARCHAR(100),  
    @Longitude VARCHAR(100),
    @Type char(1),
    @Result VARCHAR(1000) OUTPUT
AS      
BEGIN
    SET NOCOUNT ON;

    DECLARE @Date1 DATETIME;
    DECLARE @Date2 DATETIME;
    DECLARE @TimeDifference INT;

    IF @Type = 'T'
    BEGIN
        SELECT TOP 1 @Date1 = Date
        FROM Tbl_GeoLocationTracking
        WHERE EmpID = @Emp_ID AND CmpID = @Cmp_ID AND Latitude = @Latitude AND Longitude = @Longitude AND Date <= @Date
        ORDER BY Date ASC;

        SELECT TOP 1 @Date2 = Date
        FROM Tbl_GeoLocationTracking
        WHERE EmpID = @Emp_ID AND CmpID = @Cmp_ID AND Latitude = @Latitude AND Longitude = @Longitude AND Date <= @Date
        ORDER BY Date DESC;

        IF @Date1 IS NOT NULL AND @Date2 IS NOT NULL
        BEGIN
            SET @TimeDifference = DATEDIFF(MINUTE, @Date1, @Date2);
			print  @TimeDifference
            IF @TimeDifference > 30
            BEGIN
                SET @Result = 'Spent Time is more than 30 minutes';
				print @Result
            END
            ELSE IF @TimeDifference > 10
            BEGIN
                SET @Result = 'Spent Time is more than 10 minutes';
				print @Result
            END
            ELSE
            BEGIN
                SET @Result = 'Spent Time is less than 10 minutes';
				print @Result
            END
        END
        ELSE
        BEGIN
            SET @Result = 'No records found for the given criteria';
			print @Result
        END
    END
    ELSE
    BEGIN
        SET @Result = 'Invalid Type parameter';
		print @Result
    END
END;
