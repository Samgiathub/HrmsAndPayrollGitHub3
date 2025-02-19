
CREATE View [dbo].[V0080_File_apr_Admin_Side]
As

select distinct fa.File_App_Id as FA_Id,(cast(isnull(app.File_Apr_Id,0)as varchar)+'$'+cast(fa.File_App_Id as varchar)) as Id,isnull(app.File_Apr_Id,0)as File_Apr_Id,fa.File_App_Id,fa.Emp_ID,em.Alpha_Emp_Code,em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name, fa.F_StatusId,
--fs.StatusTitle as ApplicationStatus,
fsc.S_Name as Status,
ft.TypeTitle,fa.File_Number,fa.Subject,fa.Description,format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,fa.File_App_Doc,fa.F_TypeId
,isnull(app.Forward_Emp_Id,0)as Forward_Emp_Id,isnull(app.Submit_Emp_Id,0)as Submit_Emp_Id,
FORMAT(IsNull(app.Approve_Date,GetDate()), 'dd/MM/yyyy') as Approve_Date
--isnull(format(app.Approve_Date,'dd/MM/yyyy'),'')as Approve_Date

from T0080_File_Application fa
left join T0080_File_Approval app on app.File_App_Id=fa.File_App_Id
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = fa.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
