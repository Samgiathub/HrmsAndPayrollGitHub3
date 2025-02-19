






 
CREATE  VIEW [dbo].[V0100_TS_Application_BCKP_02012023]                
as                
SELECT Distinct tta.Timesheet_ID, Employee_ID, Timesheet_Period, Timesheet_Type,convert(varchar(20),Entry_Date,103)as 'Entry_Date',                
Total_Time,isnull(TTA.Project_Status_ID,0) AS 'Project_Status_ID' ,tsm.Project_ID, tta.Task_ID,(EM.Emp_First_Name +' '+EM.Emp_Last_Name ) as 'EmpName',                
TTA.Cmp_ID,isnull(PS.Project_Status,'Not Submitted')AS 'Project_Status',TTA.Description ,EM.Emp_Superior,EM.Alpha_Emp_Code,EM.Emp_Full_Name,      
isnull(ps.Color,'#000000') AS 'TSColor',tta.Attachment,EM.Branch_ID,Project_Code,tad.Client_id  --,ERD.R_Emp_ID             
FROM T0100_TS_Application TTA  WITH (NOLOCK)               
Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TTA.Employee_ID = EM.Emp_ID                
LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TTA.Project_Status_ID = PS.Project_Status_ID            
left  join T0040_TS_Project_Master tsm WITH (NOLOCK) ON tsm.Project_ID = tta.Project_ID
left outer join T0110_TS_Application_Detail tad WITH (NOLOCK) ON tad.Timesheet_ID = tta.Timesheet_ID
--LEFT JOIN T0090_EMP_REPORTING_DETAIL ERD ON EM.Emp_ID = ERD.Emp_ID

 


