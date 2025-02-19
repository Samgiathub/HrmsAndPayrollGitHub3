create PROCEDURE [dbo].[Calculate_Time_Difference123]
    @Emp_ID int,
    @Cmp_ID int,
    @Date DATETIME,
    @Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @TimeDifference INT;

    ;WITH MinDate AS
    (
        SELECT 
            latitude, 
            longitude, 
            Empid, 
            CmpID, 
            MIN(Date) AS min_date,
            MAX(Date) AS max_date
        FROM Tbl_GeoLocationTracking
        WHERE CONVERT(date, Date, 103) = @Date 
            AND CmpID = @Cmp_ID 
            AND Empid = @Emp_ID
        GROUP BY latitude, longitude, Empid, CmpID
    )
    SELECT @TimeDifference = DATEDIFF(MINUTE, min_date, max_date) FROM MinDate;

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
