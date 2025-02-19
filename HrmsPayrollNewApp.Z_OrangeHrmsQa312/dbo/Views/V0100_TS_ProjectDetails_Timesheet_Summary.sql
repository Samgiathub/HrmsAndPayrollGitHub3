

CREATE VIEW [dbo].[V0100_TS_ProjectDetails_Timesheet_Summary]        
AS 

-- TTA.Entry_Date commented by rajput 
SELECT distinct (CASE WHEN TTA.Timesheet_Type = 'Daily' THEN cast(TTA.Entry_Date as varchar(50)) ELSE (LEFT(Replace(Timesheet_Period,' TO ','#'),CHARINDEX('#',Replace(Timesheet_Period,' TO ','#'))-1)) END) AS 'FromDate',       
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN cast(TTA.Entry_Date as varchar(50)) ELSE (right(Replace(Timesheet_Period,' TO ','#'),LEN(Replace(Timesheet_Period,' TO ','#'))-CHARINDEX('#',Replace(Timesheet_Period,' TO ','#') ))) END) AS 'TODate',  
Timesheet_Period ,  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN dbo.F_Return_Sec(TTA.Total_Time) ELSE (dbo.F_Return_Sec((LEFT(Mon,CHARINDEX('#',Mon )-1)))) END) AS 'Monday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Tue,CHARINDEX('#',Tue )-1)))) END) AS 'Tuesday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Wed,CHARINDEX('#',Wed )-1)))) END) AS 'Wednesday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Thu,CHARINDEX('#',Thu )-1)))) END) AS 'Thursday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Fri,CHARINDEX('#',Fri )-1)))) END) AS 'Friday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Sat,CHARINDEX('#',Sat )-1)))) END) AS 'Saturday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN 0 ELSE (dbo.F_Return_Sec((LEFT(Sun,CHARINDEX('#',Sun )-1)))) END) AS 'Sunday',  
(CASE WHEN TTA.Timesheet_Type = 'Daily' THEN (dbo.F_Return_Sec(TTA.Total_Time)) ELSE (dbo.F_Return_Sec((LEFT(Mon,CHARINDEX('#',Mon )-1))) + dbo.F_Return_Sec((LEFT(Tue,CHARINDEX('#',Tue )-1))) +  dbo.F_Return_Sec((LEFT(Wed,CHARINDEX('#',Wed )-1))) +       
dbo.F_Return_Sec((LEFT(Thu,CHARINDEX('#',Thu )-1)))+  dbo.F_Return_Sec((LEFT(Fri,CHARINDEX('#',Fri )-1)))+  dbo.F_Return_Sec((LEFT(Sat,CHARINDEX('#',Sat )-1)))+      
dbo.F_Return_Sec((LEFT(Sun,CHARINDEX('#',Sun )-1)))) END) AS 'TotalSecond',(EM.Alpha_Emp_Code +' - '+ EM.Emp_First_Name +' '+ISNULL(EM.Emp_Second_Name,'') +' '+EM.Emp_Last_Name) AS 'EmpName',
EM.Emp_Superior --,ERD.R_Emp_ID 
,EM.Dept_ID,EM.Desig_Id,TTA.Project_Status_ID,TAD.Project_ID,TTA.Task_ID,TTA.Cmp_ID,PS.Project_Status,
TTA.Employee_ID, TTA.Timesheet_ID,TPM.Project_Name,TTA.Timesheet_Type,EM.Alpha_Emp_Code ,EM.Emp_Full_Name,TM.Task_Name,
TM.Task_Code,TAD.Timesheet_Detail_ID      
FROM T0100_TS_Application TTA WITH (NOLOCK)   
LEFT JOIN T0110_TS_Application_Detail TAD WITH (NOLOCK) ON TTA.Timesheet_ID = TAD.Timesheet_ID       
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TTA.Employee_ID = EM.Emp_ID       
LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TTA.Project_Status_ID = PS.Project_Status_ID        
INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) ON EM.Emp_ID = ERD.Emp_ID        
left JOIN T0040_TS_Project_Master TPM WITH (NOLOCK) ON TAD.Project_ID = TPM.Project_ID --OR TTA.Project_ID = TPM.Project_ID --OR TAD.Project_ID = TPM.Project_ID
left JOIN T0040_Task_Master TM WITH (NOLOCK) ON TAD.Task_ID = TM.Task_ID --OR TTA.Task_ID = TM.Task_ID --OR TAD.Task_ID = TM.Task_ID

-- Code for Only Weekly Timesheet        
--SELECT distinct (LEFT(Replace(Timesheet_Period,' TO ','#'),CHARINDEX('#',Replace(Timesheet_Period,' TO ','#'))-1)) AS 'FromDate',       
--(right(Replace(Timesheet_Period,' TO ','#'),LEN(Replace(Timesheet_Period,' TO ','#'))-CHARINDEX('#',Replace(Timesheet_Period,' TO ','#') ))) AS 'TODate',  
--Timesheet_Period ,  
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Mon,'.',' '),'#','.'),2))) 'Monday',     
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Tue,'.',' '),'#','.'),2))) 'Tuesday' ,      
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Wed,'.',' '),'#','.'),2))) 'Wednesday',  (dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Thu,'.',' '),'#','.'),2))) 'Thursday',      
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Fri,'.',' '),'#','.'),2))) 'Friday' , (dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Sat,'.',' '),'#','.'),2))) 'Saturday',      
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Sun,'.',' '),'#','.'),2))) 'Sunday',        
----(dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Mon,'.',' '),'#','.'),2)) + dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Tue,'.',' '),'#','.'),2)) +  dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Wed,'.',' '),'#','.'),2))+       
---- dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Thu,'.',' '),'#','.'),2))+  dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Fri,'.',' '),'#','.'),2))+  dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Sat,'.',' '),'#','.'),2))+      
---- dbo.F_Return_Sec(PARSENAME(REPLACE(Replace(Sun,'.',' '),'#','.'),2))) as 'TotalSecond' ,  
   
   
-- (dbo.F_Return_Sec((LEFT(Mon,CHARINDEX('#',Mon )-1)))) AS 'Monday',  
--(dbo.F_Return_Sec((LEFT(Tue,CHARINDEX('#',Tue )-1)))) AS 'Tuesday',  
--(dbo.F_Return_Sec((LEFT(Wed,CHARINDEX('#',Wed )-1)))) AS 'Wednesday',  
--(dbo.F_Return_Sec((LEFT(Thu,CHARINDEX('#',Thu )-1)))) AS 'Thursday',  
--(dbo.F_Return_Sec((LEFT(Fri,CHARINDEX('#',Fri )-1)))) AS 'Friday',  
--(dbo.F_Return_Sec((LEFT(Sat,CHARINDEX('#',Sat )-1)))) AS 'Saturday',  
--(dbo.F_Return_Sec((LEFT(Sun,CHARINDEX('#',Sun )-1)))) AS 'Sunday',  
--(dbo.F_Return_Sec((LEFT(Mon,CHARINDEX('#',Mon )-1))) + dbo.F_Return_Sec((LEFT(Tue,CHARINDEX('#',Tue )-1))) +  dbo.F_Return_Sec((LEFT(Wed,CHARINDEX('#',Wed )-1))) +       
-- dbo.F_Return_Sec((LEFT(Thu,CHARINDEX('#',Thu )-1)))+  dbo.F_Return_Sec((LEFT(Fri,CHARINDEX('#',Fri )-1)))+  dbo.F_Return_Sec((LEFT(Sat,CHARINDEX('#',Sat )-1)))+      
--dbo.F_Return_Sec((LEFT(Sun,CHARINDEX('#',Sun )-1)))) as 'TotalSecond' ,  
   
-- (EM.Emp_First_Name +' '+EM.Emp_Last_Name ) as 'EmpName',EM.Emp_Superior,ERD.R_Emp_ID,EM.Dept_ID,EM.Desig_Id,   
-- TTA.Project_Status_ID,TAD.Project_ID,TAD.Task_ID,TTA.Cmp_ID,PS.Project_Status,TTA.Employee_ID, TTA.Timesheet_ID,TPM.Project_Name,TTA.Timesheet_Type      
-- ,EM.Alpha_Emp_Code ,EM.Emp_Full_Name ,TM.Task_Name ,TM.Task_Code      
-- FROM T0100_TS_Application TTA      
-- LEFT JOIN T0110_TS_Application_Detail TAD ON TTA.Timesheet_ID = TAD.Timesheet_ID       
-- INNER JOIN T0080_EMP_MASTER EM ON TTA.Employee_ID = EM.Emp_ID       
-- LEFT JOIN T0040_Project_Status PS ON TTA.Project_Status_ID = PS.Project_Status_ID        
-- LEFT JOIN T0090_EMP_REPORTING_DETAIL ERD ON EM.Emp_ID = ERD.Emp_ID        
-- LEFT join T0040_TS_Project_Master TPM on TPM.Project_ID=TAD.Project_ID      
-- LEFT join T0040_Task_Master TM on TAD.Task_ID=TM.Task_ID     
--where Timesheet_Type = 'Weekly'   



