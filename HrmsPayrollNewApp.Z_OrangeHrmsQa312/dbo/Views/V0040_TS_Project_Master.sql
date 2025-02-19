


 
 
CREATE  VIEW [dbo].[V0040_TS_Project_Master]
AS

SELECT PM.Project_ID,Project_Name,PD.Branch_ID, PM.Cmp_ID,Overhead_Calculation 
FROM T0040_TS_Project_Master PM WITH (NOLOCK)
INNER JOIN T0050_TS_Project_Detail PD WITH (NOLOCK) ON PM.Project_ID = PD.Project_ID
INNER JOIN T0040_Project_Status PS WITH (NOLOCK) ON PM.Project_Status_ID = PS.Project_Status_ID
WHERE PS.Project_Status = 'Active'


 

