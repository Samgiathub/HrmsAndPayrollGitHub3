-- =============================================  
-- Author:  <Mr.Mehul>  
-- Create date: <22-Nov-2022>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_GET_TIMESHEET_EMP_DETAILS]   
 -- Add the parameters for the stored procedure here  
 @Cmp_id numeric,  
 @Emp_id numeric,  
 @Project_Status_ID numeric,  
 @Timesheet_Type varchar(500) = ''  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
  declare @sttype as numeric   
  Select @sttype = Project_Status_ID from T0040_Project_Status where cmp_id = @cmp_id and status_type = @Project_Status_ID  
  
     IF OBJECT_ID('dbo.TimeSheet') IS NOT NULL  
     BEGIN  
      DROP TABLE TimeSheet  
     END  
  
  Select * into #Emp_Cons from   
  (SELECT DISTINCT emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code   
  FROM V0080_Employee_Master   
  WHERE emp_id in (select emp_id   
      from t0080_emp_master   
      where emp_superior=@Emp_ID and Cmp_ID=@Cmp_ID   
       and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120))))  
  union   
  select distinct emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code from V0080_Employee_Master   
  where emp_id in (select ERD.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD INNER JOIN --Ankit 28012015  
        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1  
         where ERD1.Effect_Date <= getdate() AND Emp_ID IN (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WHERE R_Emp_ID = @Emp_ID)  
        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date  
  where R_Emp_ID = @Emp_ID and Reporting_Method = 'Direct')   
   and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))) as TP  
      
  
  SELECT Distinct tta.Timesheet_ID, Employee_ID, Timesheet_Period, Timesheet_Type,convert(varchar(20),Entry_Date,103)as 'Entry_Date',                  
  Total_Time,isnull(TTA.Project_Status_ID,0) AS 'Project_Status_ID' ,tsm.Project_ID, tta.Task_ID,(EM.Emp_First_Name +' '+EM.Emp_Last_Name ) as 'EmpName',                  
  TTA.Cmp_ID,isnull(PS.Project_Status,'Not Submitted')AS 'Project_Status',TTA.Description ,EM.Emp_Superior,EM.Alpha_Emp_Code,EM.Emp_Full_Name,        
  isnull(ps.Color,'#000000') AS 'TSColor',tta.Attachment,EM.Branch_ID,Project_Code,tad.Client_id    
  into TimeSheet  
  FROM T0100_TS_Application TTA  WITH (NOLOCK)                 
  Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TTA.Employee_ID = EM.Emp_ID                  
  LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TTA.Project_Status_ID = PS.Project_Status_ID              
  left  join T0040_TS_Project_Master tsm WITH (NOLOCK) ON tsm.Project_ID = tta.Project_ID  
  left outer join T0110_TS_Application_Detail tad WITH (NOLOCK) ON tad.Timesheet_ID = tta.Timesheet_ID  
  Inner join  #Emp_Cons Ec WITH (NOLOCK) ON Ec.Emp_ID = tta.Employee_ID  
  where TTA.Cmp_ID = @Cmp_id and TTA.Project_Status_ID = @sttype  
  
  select * from TimeSheet  
END  
  
drop table #Emp_Cons  
--drop table TimeSheet  
  
  