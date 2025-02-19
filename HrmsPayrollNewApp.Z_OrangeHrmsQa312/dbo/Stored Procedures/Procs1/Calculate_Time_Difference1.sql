


CREATE PROCEDURE [dbo].[Calculate_Time_Difference1]
    @Emp_ID int,
    @Cmp_ID int,
    @Date DATEtime,
	@Result VARCHAR(100) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
 DECLARE @TimeDifference int
 

;WITH
MinDate 
AS
(
    SELECT 
        latitude, 
        longitude, 
        Empid, 
        CmpID, 
        MIN(Date) AS min_date,Max(date) as Max_date
    FROM Tbl_GeoLocationTracking
    WHERE CONVERT(date, Date, 103) = @Date AND CmpID = @Cmp_ID AND Empid =@Emp_ID
    GROUP BY latitude, longitude, Empid, CmpID
    HAVING COUNT(*) > 1
)
select @TimeDifference=DATEDIFF(MINUTE, min_date, Max_date)  from MinDate;
       

print @TimeDifference
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
IF @TimeDifference >= 30
BEGIN
   set @Result='Spent Time  is more than 30 minutes'
	select @Result as Msg
END
end

--exec Calculate_Time_Difference1 @Emp_ID=28199, @Cmp_id=187,@Date='2024-04-04',@Result=''
--SELECT 
--    G.latitude, 
--    G.longitude, 
--    G.Empid, 
--    G.CmpID,
--    G.Date,
--    DATEDIFF(minute, M.min_date, G.Date) AS minutes_difference
--FROM Tbl_GeoLocationTracking AS G
--JOIN MinDate AS M ON G.latitude = M.latitude 
--                  AND G.longitude = M.longitude 
--                  AND G.Empid = M.Empid 
--                  AND G.CmpID = M.CmpID
--WHERE CONVERT(date, G.Date, 103) = '2024-04-02' AND G.CmpID = 187 AND G.Empid = 28201;
