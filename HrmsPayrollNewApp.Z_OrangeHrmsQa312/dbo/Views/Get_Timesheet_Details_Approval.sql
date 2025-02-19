CREATE VIEW [dbo].[Get_Timesheet_Details_Approval]
AS


--(LEFT(Mon,CHARINDEX('#',Mon )-1)) AS 'Monday',(right(Mon,LEN(Mon) - CHARINDEX('#',Mon))) AS 'Monday_Des',
--(LEFT(Tue,CHARINDEX('#',Tue )-1)) AS 'Tuesday',(right(Tue,LEN(Tue) - CHARINDEX('#',Tue))) AS 'Tuesday_Des',
--(LEFT(Wed,CHARINDEX('#',Wed )-1)) AS 'Wednesday',(right(Wed,LEN(Wed) - CHARINDEX('#',Wed))) AS 'Wednesday_Des',
--(LEFT(Thu,CHARINDEX('#',Thu )-1)) AS 'Thursday',(right(Thu,LEN(Thu) - CHARINDEX('#',Thu))) AS 'Thursday_Des',
--(LEFT(Fri,CHARINDEX('#',Fri )-1)) AS 'Friday',(right(Mon,LEN(Mon) - CHARINDEX('#',Fri))) AS 'Friday_Des',
--(LEFT(Sat,CHARINDEX('#',Sat )-1)) AS 'Saturday',(right(Sat,LEN(Sat) - CHARINDEX('#',Sat))) AS 'Saturday_Des',
--(LEFT(Sun,CHARINDEX('#',Sun )-1)) AS 'Sunday',(right(Sun,LEN(Sun) - CHARINDEX('#',Sun))) AS 'Sunday_Des',
SELECT DISTINCT TAD.Timesheet_ID,TAD.Project_ID,TAD.Task_ID ,CM.Client_ID,CM.Client_Name,TPM.Project_Code,
(LEFT(tapd.Mon,CHARINDEX('#',tapd.Mon )-1)) AS 'Monday',SUBSTRING(tapd.Mon,CHARINDEX('#',tapd.Mon)+1,LEN(tapd.Mon)) AS 'Monday_Des',
(LEFT(tapd.Tue,CHARINDEX('#',tapd.Tue )-1)) AS 'Tuesday',SUBSTRING(tapd.Tue,CHARINDEX('#',tapd.Tue)+1,LEN(tapd.Tue)) AS 'Tuesday_Des',
(LEFT(tapd.Wed,CHARINDEX('#',tapd.Wed )-1)) AS 'Wednesday',SUBSTRING(tapd.Wed,CHARINDEX('#',tapd.Wed)+1,LEN(tapd.Wed)) AS 'Wednesday_Des',
(LEFT(tapd.Thu,CHARINDEX('#',tapd.Thu )-1)) AS 'Thursday',SUBSTRING(tapd.Thu,CHARINDEX('#',tapd.Thu)+1,LEN(tapd.Thu)) AS 'Thursday_Des',
(LEFT(tapd.Fri,CHARINDEX('#',tapd.Fri )-1)) AS 'Friday',SUBSTRING(tapd.Fri,CHARINDEX('#',tapd.Fri)+1,LEN(tapd.Fri)) AS 'Friday_Des',
(LEFT(tapd.Sat,CHARINDEX('#',tapd.Sat )-1)) AS 'Saturday',SUBSTRING(tapd.Sat,CHARINDEX('#',tapd.Sat)+1,LEN(tapd.Sat)) AS 'Saturday_Des',
(LEFT(tapd.Sun,CHARINDEX('#',tapd.Sun )-1)) AS 'Sunday',SUBSTRING(tapd.Sun,CHARINDEX('#',tapd.Sun)+1,LEN(tapd.Sun)) AS 'Sunday_Des',
TPM.Project_Name,TTM.Task_Name,TAD.Cmp_ID,ta.Timesheet_Period,Ta.Project_Status_ID,Project_Status,TA.Description,Ps.Color as TSColor,TA.Attachment  
FROM T0110_TS_Application_Detail TAD WITH (NOLOCK)  
inner JOIN T0040_TS_Project_Master TPM WITH (NOLOCK) ON TAD.Project_ID = TPM.Project_ID  
left outer JOIN T0040_Task_Master TTM WITH (NOLOCK) ON TAD.Task_ID = TTM.Task_ID 
LEft outer join T0040_Client_Master CM WITH (NOLOCK) ON CM.Cmp_ID = TAD.Cmp_ID
left outer join T0100_TS_Application TA WITH (NOLOCK) ON TA.Timesheet_ID = TAD.Timesheet_ID
left outer join T0040_Project_Status PS WITH (NOLOCK) ON PS.Project_Status_ID = TPM.Project_Status_ID
left outer join T0120_TS_Approval TSA WITH (NOLOCK) ON TSA.Timesheet_ID = TAD.Timesheet_ID
left outer join T0130_TS_Approval_Detail TAPD WITH (NOLOCK) ON TAPD.Project_ID = TAD.Project_ID and TAPD.Timesheet_Approval_ID = TSA.Timesheet_Approval_ID
