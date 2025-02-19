










CREATE VIEW [dbo].[Get_Timesheet_Details]
AS

SELECT Timesheet_Detail_ID,TAD.Timesheet_ID,TAD.Project_ID,TAD.Task_ID ,CM.Client_ID,CM.Client_Name,TPM.Project_Code,
--(LEFT(Mon,CHARINDEX('#',Mon )-1)) AS 'Monday',(right(Mon,LEN(Mon) - CHARINDEX('#',Mon))) AS 'Monday_Des',
--(LEFT(Tue,CHARINDEX('#',Tue )-1)) AS 'Tuesday',(right(Tue,LEN(Tue) - CHARINDEX('#',Tue))) AS 'Tuesday_Des',
--(LEFT(Wed,CHARINDEX('#',Wed )-1)) AS 'Wednesday',(right(Wed,LEN(Wed) - CHARINDEX('#',Wed))) AS 'Wednesday_Des',
--(LEFT(Thu,CHARINDEX('#',Thu )-1)) AS 'Thursday',(right(Thu,LEN(Thu) - CHARINDEX('#',Thu))) AS 'Thursday_Des',
--(LEFT(Fri,CHARINDEX('#',Fri )-1)) AS 'Friday',(right(Mon,LEN(Mon) - CHARINDEX('#',Fri))) AS 'Friday_Des',
--(LEFT(Sat,CHARINDEX('#',Sat )-1)) AS 'Saturday',(right(Sat,LEN(Sat) - CHARINDEX('#',Sat))) AS 'Saturday_Des',
--(LEFT(Sun,CHARINDEX('#',Sun )-1)) AS 'Sunday',(right(Sun,LEN(Sun) - CHARINDEX('#',Sun))) AS 'Sunday_Des',

(LEFT(Mon,CHARINDEX('#',Mon )-1)) AS 'Monday',SUBSTRING(Mon,CHARINDEX('#',Mon)+1,LEN(Mon)) AS 'Monday_Des',
(LEFT(Tue,CHARINDEX('#',Tue )-1)) AS 'Tuesday',SUBSTRING(Tue,CHARINDEX('#',Tue)+1,LEN(Tue)) AS 'Tuesday_Des',
(LEFT(Wed,CHARINDEX('#',Wed )-1)) AS 'Wednesday',SUBSTRING(Wed,CHARINDEX('#',Wed)+1,LEN(Wed)) AS 'Wednesday_Des',
(LEFT(Thu,CHARINDEX('#',Thu )-1)) AS 'Thursday',SUBSTRING(Thu,CHARINDEX('#',Thu)+1,LEN(Thu)) AS 'Thursday_Des',
(LEFT(Fri,CHARINDEX('#',Fri )-1)) AS 'Friday',SUBSTRING(Fri,CHARINDEX('#',Fri)+1,LEN(Fri)) AS 'Friday_Des',
(LEFT(Sat,CHARINDEX('#',Sat )-1)) AS 'Saturday',SUBSTRING(Sat,CHARINDEX('#',Sat)+1,LEN(Sat)) AS 'Saturday_Des',
(LEFT(Sun,CHARINDEX('#',Sun )-1)) AS 'Sunday',SUBSTRING(Sun,CHARINDEX('#',Sun)+1,LEN(Sun)) AS 'Sunday_Des',

TPM.Project_Name,TTM.Task_Name,TAD.Cmp_ID,Timesheet_Period,Ta.Project_Status_ID,Project_Status,TA.Description,Ps.Color as TSColor,TA.Attachment  
FROM T0110_TS_Application_Detail TAD WITH (NOLOCK)  
left outer join T0100_TS_Application TA WITH (NOLOCK) ON TA.Timesheet_ID = TAD.Timesheet_ID
inner JOIN T0040_TS_Project_Master TPM WITH (NOLOCK) ON TAD.Project_ID = TPM.Project_ID  
left outer JOIN T0040_Task_Master TTM WITH (NOLOCK) ON TAD.Task_ID = TTM.Task_ID 
LEft outer join T0040_Client_Master CM WITH (NOLOCK) ON  TPM.Client_ID = CM.Client_ID --CM.Client_ID = TAD.Client_id and     Commented By Mr.Mehul on 16-04-2023
left outer join T0040_Project_Status PS WITH (NOLOCK) ON PS.Project_Status_ID = TPM.Project_Status_ID
