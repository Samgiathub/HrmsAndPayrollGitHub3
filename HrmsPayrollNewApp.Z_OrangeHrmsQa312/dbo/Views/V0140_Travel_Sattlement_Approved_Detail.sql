



------2015-09-21 16:50:00.941-----------------------------------
CREATE VIEW [dbo].[V0140_Travel_Sattlement_Approved_Detail]  
AS  
SELECT TSA.*,isnull(TSA.Payment_Type,'') as Payment_Mode,ISNULL(cast(cheque_No as varchar(200)),'')  as Chque_no,
TSA.Expance_Incured as Expence,TSA.Amount_Differnce as Credit,TSA.Manager_comment as Comment,
EM.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name as emp_name,bm.Branch_Name,'' as Document
,Travel_Amt_In_Salary as EffectSalary,
convert(varchar(11),isnull(Effect_Salary_date,GETDATE()),103) as Sal_Effect_date,c.GST_No
from T0150_Travel_Settlement_Approval
TSA WITH (NOLOCK) inner join T0080_EMP_MASTER Em WITH (NOLOCK)  on Em.Emp_ID=
TSA.Emp_ID and TSA.Cmp_ID=EM.Cmp_ID inner join
V0080_EMP_MASTER_INCREMENT_GET VEM WITH (NOLOCK)  on VEM.Emp_ID=TSA.emp_id
inner join T0030_BRANCH_MASTER bM WITH (NOLOCK)  ON bM.Branch_ID=VEM.Branch_ID
INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = TSA.cmp_id




