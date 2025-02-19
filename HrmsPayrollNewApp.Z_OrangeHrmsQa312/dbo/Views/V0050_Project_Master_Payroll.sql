


-- Created by rohit on 29122015
--created for javi System for project master Entry.
CREATE VIEW [dbo].[V0050_Project_Master_Payroll]
as
select Tran_Id,PM.Cmp_Id,Project_Name,Project_Manager_Id,Customer_Name,
Site_Id,Remarks,Modify_Date,Em.Emp_Full_Name as Project_manager
from T0050_Project_Master_Payroll PM WITH (NOLOCK)
left join T0080_EMP_MASTER EM WITH (NOLOCK) on Pm.Project_Manager_Id = Em.Emp_id 



