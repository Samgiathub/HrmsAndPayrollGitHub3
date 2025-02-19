-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[SP_GeoLocationTracing_API]
@Emp_ID NUMERIC(18,0),  
 @Cmp_ID NUMERIC(18,0), 
 @Date datetime ,
 @Latitude float , 
 @Longitude float ,
 @Address_location VARCHAR(max),
 @City VARCHAR(max),
 @Area VARCHAR(max),
 @Type char(1),
 --@Empname VARCHAR(max),
 @Result VARCHAR(100) OUTPUT
 AS      
  
SET NOCOUNT ON 
if  @Type='I'
begin
set @Date= GETDATE()
 INSERT INTO Tbl_GeoLocationTracking(EmpID,CmpID,Latitude,Longitude,Date,Address_location,City,Area)  
   VALUES(@Emp_ID,@Cmp_ID,@Latitude,@Longitude,@Date,@Address_location,@City,@Area)  
   --SET @Result = 'Inserted' 
   SELECT 'Inserted#True#'
   end
 else if  @Type='L'  ---list of data for particular employee 
begin
if exists (select EmpID from Tbl_GeoLocationTracking where EmpID=@Emp_ID and CmpID=@Cmp_ID)
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







--SELECT 
--    Date,
--    Latitude,
--    Longitude,
--    Address_location ,
--	Em.Emp_Full_Name
--FROM 
--    Tbl_GeoLocationTracking GT
--INNER JOIN 
--    T0080_EMP_MASTER EM ON GT.EmpID = EM.Emp_ID AND GT.CmpID = EM.Cmp_ID 
--WHERE 
--    Emp_ID = @Emp_ID 
--    AND Cmp_ID = @Cmp_ID 
--    AND CONVERT(date, Date, 103) = @Date;

--select Date,Latitude,Longitude, Address_location from Tbl_GeoLocationTracking where EmpID=@Emp_ID and CmpID=@Cmp_ID and convert(date,Date,103)=@Date
end
else if @Type='M'
begin 
SELECT 
    GT.Empid,
    MaxDate,
    GT.Latitude, 
    GT.Longitude, 
    GT.Cmpid, 
    GT.Address_location,
    COALESCE(EM.Image_Name, '../App_File/EMPIMAGES/Emp_Default.png') AS Image_Name,
    EM.Emp_Full_Name  
FROM 
    Tbl_GeoLocationTracking AS GT
INNER JOIN 
    T0080_EMP_MASTER AS EM ON GT.EmpID = EM.Emp_ID AND GT.CmpID = EM.Cmp_ID
INNER JOIN (
    SELECT 
        Empid, 
        MAX(Date) AS MaxDate
    FROM 
        Tbl_GeoLocationTracking
    WHERE 
        City =@City
        AND Area = @Area
    GROUP BY 
        Empid
) AS MaxDates ON GT.Empid = MaxDates.Empid AND GT.Date = MaxDates.MaxDate
WHERE 
    GT.City =@City
    AND GT.Area = @Area;

--commented ba aswini 16-04-2024
--SELECT 
--    GT.Latitude, 
--    GT.Longitude, 
--    GT.Empid, 
--    GT.Cmpid, 
--    GT.Address_location,
--    COALESCE(EM.Image_Name, '../App_File/EMPIMAGES/Emp_Default.png') AS Image_Name,
--    EM.Emp_Full_Name  
--FROM 
--    Tbl_GeoLocationTracking AS GT
--INNER JOIN 
--    T0080_EMP_MASTER AS EM ON GT.EmpID = EM.Emp_ID AND GT.CmpID = EM.Cmp_ID
--WHERE 
--    GT.City =@City 
--    AND GT.Area = @Area

--	 --AND GT.Date = (
--  --      SELECT MAX(Date) 
--  --     FROM Tbl_GeoLocationTracking  WHERE City = @City  AND Area = @Area)
         
    
--	and Gt.EmpID in (
--SELECT empid
--FROM Tbl_GeoLocationTracking
--WHERE city = @City  
--    AND area = @Area
--GROUP BY empid);

--AND GT.Date in (
    --    SELECT Date 
    --    FROM Tbl_GeoLocationTracking 
    --    WHERE city = @City 
    --AND area = @Area GROUP BY date
  --  )  







--SELECT 
--    GT.Latitude, 
--    GT.Longitude, 
--    GT.Empid, 
--    GT.Cmpid, 
--    GT.Address_location,
--    COALESCE(EM.Image_Name, '../App_File/EMPIMAGES/Emp_Default.png') AS Image_Name,
--    EM.Emp_Full_Name  
--FROM 
--    Tbl_GeoLocationTracking AS GT
--INNER JOIN 
--    T0080_EMP_MASTER AS EM ON GT.EmpID = EM.Emp_ID AND GT.CmpID = EM.Cmp_ID
--WHERE 
--    GT.City = @City 
--    AND GT.Area = @Area 
--    AND GT.Date = (
--        SELECT MAX(Date) 
--        FROM Tbl_GeoLocationTracking 
--        WHERE City = @City 
--        AND Area = @Area
--    );
end
else if @Type='A'
begin 
Select distinct Area from Tbl_GeoLocationTracking WHERE City = @City

end
--SELECT 
--    GT.Latitude, 
--    GT.Longitude, 
--    GT.Empid, 
--    GT.Cmpid, 
--    GT.Address_location,
--    EM.Image_Name,EM.Emp_Full_Name  -- Assuming ImagePath is the column in emp_master that stores the image path
--FROM 
--    Tbl_GeoLocationTracking AS GT
--INNER JOIN 
--    T0080_EMP_MASTER AS EM ON GT.EmpID = EM.Emp_ID and GT.CmpID=EM.Cmp_ID
--WHERE 
--    GT.City = @City 
--    AND GT.Area = @Area 
--    AND GT.Date = (
--        SELECT MAX(Date) 
--        FROM Tbl_GeoLocationTracking 
--        WHERE City = @City 
--        AND Area = @Area
--    );

--select Latitude,longitude , Empid,Cmpid, Address_location from Tbl_GeoLocationTracking  where City=@City and Area=@Area and Date =
--(select max(date) from Tbl_GeoLocationTracking where  City=@City and Area=@Area)



