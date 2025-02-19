create PROCEDURE [dbo].[Calculate_Time_Difference_samplenewaswini_0324]
    @Emp_ID int,
    @Cmp_ID int,
    @Date datetime,
    @Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @TimeDifference int;

    SELECT @TimeDifference = DATEDIFF(MINUTE, MIN(Date), MAX(Date))
    FROM Tbl_GeoLocationTracking
    WHERE CONVERT(date, Date, 103) = @Date 
          AND CmpID = @Cmp_ID 
          AND Empid = @Emp_ID
    GROUP BY latitude, longitude
    HAVING COUNT(*) > 1;

    PRINT @TimeDifference;

    IF @TimeDifference > 10
    BEGIN
        SET @Result = 'Spent Time is more than 10 minutes';
        SELECT @Result as Msg;
    END
    ELSE
    BEGIN
        SET @Result = 'Spent Time is less than 10 minutes';
        SELECT @Result as Msg;
    END;

    IF @TimeDifference >= 30
    BEGIN
        SET @Result = 'Spent Time is more than 30 minutes';
        SELECT @Result as Msg;
    END;
END;
