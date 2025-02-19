



CREATE VIEW [dbo].[V0040_Template_Master]
AS
select T_ID,T0040_Template_Master.Cmp_ID,Template_Title,Template_Instruction,
CreatedBy, T0040_Template_Master.Branch_ID,Desig_ID,
case when  T0040_Template_Master.Branch_ID IS null then '' else  T0030_BRANCH_MASTER.branch_name end branch_name,
case when Desig_ID IS not null then
(SELECT     dm.Desig_Name + ','
FROM          T0040_DESIGNATION_MASTER dm WITH (NOLOCK)
WHERE      dm.Desig_ID IN
(SELECT     cast(data AS numeric(18, 0))
 FROM          dbo.Split(ISNULL(Desig_ID, '0'), '#')
 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END Desig_Name, 
EmpId , case when EmpId IS not null then
(SELECT     E.Emp_Full_Name + ','
FROM          T0080_EMP_MASTER E WITH (NOLOCK)
WHERE      E.Emp_ID IN
(SELECT     cast(data AS numeric(18, 0))
 FROM          dbo.Split(ISNULL(EmpId, '0'), '#')
 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Employee,
 IsActive
 --dbo.F_GET_AMPM (Start_Time)Start_Time, dbo.F_GET_AMPM (End_Time)End_Time
from T0040_Template_Master WITH (NOLOCK) 
left join T0030_BRANCH_MASTER WITH (NOLOCK)
on T0030_BRANCH_MASTER.Branch_ID = T0040_Template_Master.Branch_ID  





