create PROCEDURE [dbo].[SP_Calculate_Time_Difference_SpentTime]
    @Emp_ID int,
    @Cmp_ID int,
    @Date DATEtime,
	@Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @TimeDifference INT;
	DECLARE @Min datetime;
	DECLARE @max datetime;
--	select @max=max(date) , @Min=min(date) FROM Tbl_GeoLocationTracking
--WHERE EmpID = @Emp_ID
--AND CmpID =@Cmp_ID and convert(date,Date,103)=@Date
	SELECT @TimeDifference = DATEDIFF(MINUTE, MIN( Date), MAX( Date)), @Min=MIN( Date),@max=MAX( Date)
FROM Tbl_GeoLocationTracking
WHERE EmpID = @Emp_ID
AND CmpID = @Cmp_ID
AND convert(date,Date,103)=@Date

    --SELECT @TimeDifference = DATEDIFF(MINUTE, MIN(Date), MAX(Date))
    --FROM Tbl_GeoLocationTracking
    --WHERE EmpID = @Emp_ID
    --AND CmpID = @Cmp_ID
    --AND CAST(Date AS DATE) = @Date;
	--select @Min=MIN(Date)from Tbl_GeoLocationTracking;
	--select @Max=MAX(Date) from Tbl_GeoLocationTracking;
    SELECT @TimeDifference AS Time_Difference;
	print @Min
	print @Max
	IF @TimeDifference > 10
BEGIN
    set @Result= 'Spent Time is more than 10 minutes'
	select @Result as Msg
END
ELSE
BEGIN
    set @Result='Spent Time is less than 10 minutes'
	select @Result as Msg
END





-- Check if the time difference is more than 30 minutes
IF @TimeDifference > 30
BEGIN
   set @Result='Spent Time  is more than 30 minutes'
	select @Result as Msg
END
END;