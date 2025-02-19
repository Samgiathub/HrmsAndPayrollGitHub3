-- =============================================            
-- Author:  <Yogesh Patel>            
-- Create date: <03-01-2024,,>            
-- Description: <For Wonder Home finance POST API,,>            
-- =============================================            
   -- exec P0080_Get_Notification_API  
         
CREATE  PROCEDURE [dbo].[P0080_Get_Notification_API]    
  AS            
  BEGIN   
-- Enable OLE Automation  
EXEC sp_configure 'show advanced options', 1;  
RECONFIGURE;  
EXEC sp_configure 'Ole Automation Procedures', 1;  
RECONFIGURE;  
  
DECLARE @URL NVARCHAR(MAX) = 'http://192.168.1.200:1203/Mobile_HRMS.asmx?op=GetNotification';  
DECLARE @Object AS INT;  
DECLARE @ResponseText AS VARCHAR(8000);  
DECLARE @Body AS VARCHAR(8000) ;  
  
Create table #EmpDetails(  

Emp_id numeric(18,0),  
Cmp_id numeric(18,0),  
Deptid numeric(18,0),  
GallaryType  varchar(50),  
strType  varchar(50)
)  


--truncate table T0080_Get_EMP_Data_join_left  
insert into #EmpDetails  (Emp_id,Cmp_id,Deptid,GallaryType,strtype)
Values(28201,187,505,'0','B')
  
Declare @counter as integer=1  
  
--select * from #EmpDetails  
--drop table #EmpDetails  
--return  
 if ((select Count(*) from #EmpDetails) > 0)
  begin
--WHILE @counter <= (select Count(*) from #EmpDetails)  
--BEGIN  
set @Body=(select Emp_id  
,Cmp_id  
,Deptid
,GallaryType
,strType  

from #EmpDetails FOR JSON AUTO)  
  
--select @Body  
set @Body=REPLACE(@Body,'[','')  
set @Body=REPLACE(@Body,']','')  
 
--drop table #EmpDetails  
--return  
--END  
  
  
  
  
  
  
  
--set @Body=  
--'{  
--   "firstName": "RAjesh",  
--      "lastName": "Khanna",  
--      "emailAddress": "testuser12@wonderhfl.com",  
--      "designation": "Cluster Manager",  
--      "branchName": "REGISTERED AND HEAD OFFICE",  
--      "employeeCode": "99125",  
--      "buisness": "DIRECT",  
--      "associatedPhoneNumber": "9999989999",  
--      "managerUser": "shubham.jain2@wonderhfl.com",  
--      "deactivation": "NO",  
--   "companyCode":"WHFL",  
--   "LWD":"01/01/2024"  
--}'  
EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;  
EXEC sp_OAMethod @Object, 'open', NULL, 'get',  
                 @URL,  
                 'false'  
EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'  
EXEC sp_OAMethod @Object, 'send', null, @body  
EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT  
IF CHARINDEX('false',(SELECT @ResponseText)) > 0  
BEGIN  
 SELECT @ResponseText As 'Message'  
 --print @ResponseText --As 'Message'  
END  
ELSE  
BEGIN  
 SELECT @ResponseText As 'Employee Details'  
--print @ResponseText --As 'Employee Details'  
END  
EXEC sp_OADestroy @Object  
  
 --SET @counter = @counter + 1; 
 
-- insert into T0080_Get_EMP_Data_join_left_For_Logs (URL,object,Response,Body,timestamp) 
 --values (@URL,@Object,@ResponseText,@Body,getdate())


--End 





drop table #EmpDetails  
End
else
begin
select 'There is no updates / Data to Update'
end
end