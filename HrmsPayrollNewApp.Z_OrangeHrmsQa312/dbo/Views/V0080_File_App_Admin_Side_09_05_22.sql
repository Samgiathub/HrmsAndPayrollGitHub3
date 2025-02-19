
CREATE View [dbo].[V0080_File_App_Admin_Side_09_05_22]
As

select distinct fa.Emp_ID,em.Alpha_Emp_Code,em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,fa.File_App_Id,format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name, fa.F_StatusId,em.Emp_First_Name,
--fs.StatusTitle as ApplicationStatus,
fsc.S_Name as ApplicationStatus,
--(case when fa.F_StatusId=0 then 'Pending' else fs.StatusTitle end )as ApplicationStatus,
ft.TypeTitle,fa.File_Number,fa.Subject,fa.Description,format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,fa.File_App_Doc,fa.F_TypeId
,fa.[User ID]--added
,isnull(fa.RComments,'')as RComments--added
,isnull(fa.Review_Emp_Id,0)as Review_Emp_Id--added
from T0080_File_Application_1 FA
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = fa.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
