

CREATE View [dbo].[V0080_File_admin_appr_backup_19_08_22]
As

select distinct fa.File_App_Id as FA_Id,
(cast(isnull(fa.File_Apr_Id,0)as varchar)+'$'+cast(fa.File_App_Id as varchar)) as Id,
isnull(fa.File_Apr_Id,0)as File_Apr_Id,
fa.File_App_Id,fa.Emp_ID,em.Alpha_Emp_Code,em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,
FORMAT(IsNull(fa.Approve_Date,GetDate()), 'dd/MM/yyyy') as Application_Date,
--format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name, fa.F_StatusId,
--fs.StatusTitle as ApplicationStatus,
fsc.S_Name as Status,
ft.TypeTitle,fa.File_Number,fa.Subject,fa.Description,format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,fa.File_App_Doc,fa.F_TypeId
,isnull(fa.Forward_Emp_Id,0)as Forward_Emp_Id,isnull(fa.Submit_Emp_Id,0)as Submit_Emp_Id,
FORMAT(IsNull(fa.Approve_Date,GetDate()), 'dd/MM/yyyy') as Approve_Date,l.Login_Name
,isnull(Approval_Comments,'')as Approval_Comments,
isnull(fa.Review_Emp_Id,0)as Review_Emp_Id,isnull(fa.Reviewed_by_Emp_Id,0)as Reviewed_by_Emp_Id --added
--isnull(format(app.Approve_Date,'dd/MM/yyyy'),'')as Approve_Date
				----added 1 july start
			 -- ,efw.Emp_Full_Name as Forward_Employee
			 -- ,efwby.Emp_Full_Name as Forward_by_Employee,erw.Emp_Full_Name as Review_Employee,
			 --  erwby.Emp_Full_Name as Review_by_Employee
			 ,'' as Forward_Employee
			 --   --added 1 july end
from T0080_File_Approval fa
--left join T0080_File_Approval app on app.File_App_Id=fa.File_App_Id
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = fa.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
left join T0011_LOGIN l on l.Login_ID=fa.[User ID]
				----added on 1 july start
				--	left  join T0080_EMP_MASTER efw on efw.Emp_ID=fa.Forward_Emp_Id
				--	left  join T0080_EMP_MASTER efwby on efwby.Emp_ID=fa.Submit_Emp_Id
				--	left  join T0080_EMP_MASTER erw on erw.Emp_ID=fa.Review_Emp_Id
				--	left  join T0080_EMP_MASTER erwby on erwby.Emp_ID=fa.Reviewed_by_Emp_Id					
				----added on 1 july end
