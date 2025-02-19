




CREATE VIEW [dbo].[V0050_TemplateMaster]
AS
select T_ID,T0040_Template_Master.Cmp_ID,
--case when Start_Time <>'' then  convert(varchar(15),SurveyStart_Date,103) + ' ' + Start_Time else convert(varchar(15),SurveyStart_Date,103) end as SurveyStart_Date,
--SurveyEnd_Date,Min_Passing_Criteria,
--convert(varchar(15),Survey_OpenTill,107) as SurveyEndDate,convert(varchar(15),SurveyStart_Date,107) as SurveyStartDate
Template_Title,
--case when End_Time <>'' then  convert(varchar(15),Survey_OpenTill,103) + ' ' + End_Time else convert(varchar(15),Survey_OpenTill,103) end as Survey_OpenTill,
Template_Instruction
,CreatedBy, T0040_Template_Master.Branch_Id,
case when  T0040_Template_Master.Branch_Id IS null then '' else  T0030_BRANCH_MASTER.branch_name end branch_name,
EmpId , case when EmpId IS not null then
(SELECT     E.Emp_Full_Name + ','
FROM          T0080_EMP_MASTER E WITH (NOLOCK)
WHERE      E.Emp_ID IN
(SELECT     cast(data AS numeric(18, 0))
 FROM          dbo.Split(ISNULL(EmpId, '0'), '#')
 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Employee
--,Desig_ID,
--case when  T0040_Template_Master.Branch_Id IS null then '' else  T0030_BRANCH_MASTER.branch_name end branch_name,
--case when Desig_ID  IS not null then
--(SELECT     dm.Desig_Name + ','
--FROM          T0040_DESIGNATION_MASTER dm WITH (NOLOCK)
--WHERE      dm.Desig_ID IN
--(SELECT     cast(data AS numeric(18, 0))
-- FROM          dbo.Split(ISNULL(Desig_ID, '0'), '#')
-- WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END Desig_Name, EmpId , case when EmpId IS not null then
--(SELECT     E.Emp_Full_Name + ','
--FROM          T0080_EMP_MASTER E WITH (NOLOCK)
--WHERE      E.Emp_ID IN
--(SELECT     cast(data AS numeric(18, 0))
-- FROM          dbo.Split(ISNULL(EmpId, '0'), '#')
-- WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Employee--, Start_Time,End_Time
 --dbo.F_GET_AMPM (Start_Time)Start_Time, dbo.F_GET_AMPM (End_Time)End_Time
from T0040_Template_Master WITH (NOLOCK) 
left join T0030_BRANCH_MASTER WITH (NOLOCK)
on T0030_BRANCH_MASTER.Branch_ID = T0040_Template_Master.Branch_ID  





