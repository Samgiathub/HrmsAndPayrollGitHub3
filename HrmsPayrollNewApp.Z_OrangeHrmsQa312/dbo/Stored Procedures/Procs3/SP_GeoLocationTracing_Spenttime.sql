-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[SP_GeoLocationTracing_Spenttime]
@Emp_ID NUMERIC(18,0),  
 @Cmp_ID NUMERIC(18,0), 

 @Latitude VARCHAR(100),  
 @Longitude VARCHAR(100),
 --@Address_location VARCHAR(max),
 @Type char(1),
 @Result VARCHAR(100) OUTPUT
 AS      
  DECLARE @Date1 DATETIME
DECLARE @Date2 DATETIME
DECLARE @TimeDifference float
SET NOCOUNT ON 
if  @Type='T'
begin
SELECT TOP 1  @Date1 = Date
FROM Tbl_GeoLocationTracking
WHERE Latitude = @Latitude AND Longitude = @Longitude and EmpID=@Emp_ID and CmpID=@Cmp_ID  
ORDER BY Date ASC;

SELECT TOP 1  @Date2 = Date
FROM Tbl_GeoLocationTracking
WHERE Latitude = @Latitude AND Longitude = @Longitude and EmpID=@Emp_ID  and CmpID=@Cmp_ID 
ORDER BY Date desc;

SET @TimeDifference = DATEDIFF(MINUTE, @Date1, @Date2)
print @Date1 
print @Date2
print  @TimeDifference
-- Check if the time difference is more than 10 minutes
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





end