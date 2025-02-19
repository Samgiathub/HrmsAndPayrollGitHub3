
 
CREATE  VIEW [dbo].[V0040_TS_Project_Master_Ahana]
AS

select Project_ID,Project_Name,Project_Code,Project_Description,convert(varchar(20),Start_Date,103) as 'Start_Date',
convert(varchar(20),Due_Date,103) as 'Due_Date',Duration,Project_Status_ID,TimeSheet_Approval_Type,Completed,Disabled,Client_Name,Pm.Cmp_ID 
from T0040_TS_Project_Master Pm 
left join T0040_Client_Master Cm on Cm.Client_ID = Pm.Client_ID 
 

