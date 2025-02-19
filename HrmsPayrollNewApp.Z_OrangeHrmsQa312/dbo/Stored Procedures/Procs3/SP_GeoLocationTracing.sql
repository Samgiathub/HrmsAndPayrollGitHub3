CREATE procedure [dbo].[SP_GeoLocationTracing]
@Emp_ID NUMERIC(18,0),  
 @Cmp_ID NUMERIC(18,0), 
 @Date datetime ,
 --@Latitude VARCHAR(100),  
 --@Longitude VARCHAR(100),
 --@Address_location VARCHAR(max),
@Type Char(1)
-- @Result VARCHAR(100) OUTPUT
 AS      
  
SET NOCOUNT ON  


IF @Type = 'V'
begin
select EmpID as EmpCode,CmpID,Latitude,Longitude,Address_Location as Location,Date from Tbl_GeoLocationTracking where EmpID=@Emp_ID and convert(date,Date,103)=@Date and CmpID=@Cmp_ID
   end
   IF @Type = 'G'
   begin
   select Emp_Full_Name from T0080_EMP_MASTER where Cmp_ID=@Cmp_ID and Emp_id=@Emp_ID
   end
   --select EmpID as EmpCode,CmpID,Latitude,Longitude,Address_Location as Location,Date from Tbl_GeoLocationTracking where EmpID=@Emp_ID and convert(date,Date,103)=@Date and CmpID=@Cmp_ID
