



CREATE View [dbo].[V0080_File_app_data_SentBack]
As



select distinct 
FH_ID,fh.File_App_Id as FA_Id,(cast(0 as varchar)+'$'+cast(fh.File_App_Id as varchar)) as Id,
0 as File_Apr_Id,fh.File_App_Id,fh.Emp_ID,em.Alpha_Emp_Code,
em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,
format(f.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name,
fh.H_F_StatusId  as F_StatusId,
--fs.StatusTitle as ApplicationStatus,
fsc.S_Name   as Status,
ft.TypeTitle,fh.H_File_Number as File_Number,
fh.H_Subject as Subject ,
isnull(fh.H_Description,'') as Description,
format(fh.H_Process_Date,'dd/MM/yyyy') as Process_Date,
f.Branch_Id,f.Dept_Id,f.Desig_Id,fh.H_S_Emp_Id as S_Emp_Id,fh.Cmp_ID,
fh.H_File_App_Doc as File_App_Doc,
--(case when File_Apr_Id<>0 then app.File_App_Doc else fa.File_App_Doc end)as File_App_Doc,
 fh.H_F_TypeId as F_TypeId,
0 as Forward_Emp_Id,
0 as Submit_Emp_Id,fh.H_Review_Emp_Id as Review_Emp_Id,fh.H_Reviewed_by_Emp_Id as Reviewed_by_Emp_Id,
FORMAT(GetDate(), 'dd/MM/yyyy') as Approve_Date
,'' as Approval_Comments,
'' as forwarded_by
,'' updated_by 
 ,fh.[User ID] as applicant
 ,eapp.Emp_Full_Name as application_by
--isnull(format(app.Approve_Date,'dd/MM/yyyy'),'')as Approve_Date

from T0115_File_Level_Approval_History fh
left join T0080_File_Application f on f.File_App_Id=fh.File_App_Id

--left join T0080_File_Approval app on app.File_App_Id=fa.File_App_Id
left join T0080_EMP_MASTER as em on em.Emp_ID = f.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = f.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = f.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = f.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = f.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = f.F_StatusId
--left join T0030_File_Status_Common as fapc on fapc.S_ID = app.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = f.F_TypeID
left join T0011_LOGIN as lgapp on lgapp.Login_ID=fh.[User ID]
left join T0080_EMP_MASTER as eapp on eapp.Emp_ID = lgapp.Emp_ID
where H_F_StatusId=5 and FH_ID=(select Max(FH_ID) from T0115_File_Level_Approval_History)










