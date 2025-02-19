



 
CREATE VIEW [dbo].[V0040_Task_Master]    
AS    
SELECT  TM.Task_ID,TM.Project_ID,TM.Task_Name,TM.Task_Code,TM.Task_Description, TM.Task_Type_ID,TM.Task_Priority,TM.Project_Status_ID,     
TPM.Project_Name,TTM.TaskType_Name,TM.Cmp_ID,IsReOpen,
CASE WHEN TM.IsReOpen=1 THEN 'awards_link'	
WHEN TM.IsReOpen=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END  as Status_Color,
CASE WHEN TM.IsReOpen=1 THEN 1 ELSE 0 END AS IsActive

from T0040_Task_Master TM  WITH (NOLOCK)   
LEFT JOIN T0040_Task_Type_Master TTM WITH (NOLOCK) on TM.Task_Type_ID = TTM.Task_Type_ID     
INNER JOIN T0040_TS_Project_Master TPM WITH (NOLOCK) on TM.Project_ID = TPM.Project_ID 
--WHERE TM.IsReOpen = 1


