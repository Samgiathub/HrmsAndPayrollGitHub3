


CREATE View [dbo].[V0080_File_app_data]
As

select distinct fa.File_App_Id as FA_Id,(cast(0 as varchar)+'$'+cast(fa.File_App_Id as varchar)) as Id,
0 as File_Apr_Id,fa.File_App_Id,fa.Emp_ID,em.Alpha_Emp_Code,
em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,
format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name,
fa.F_StatusId  as F_StatusId,
fsc.S_Name   as Status,
ft.TypeTitle,fa.File_Number,
fa.Subject ,
isnull(fa.Description,'') as Description,
format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,
fa.File_App_Doc as File_App_Doc,
--(case when File_Apr_Id<>0 then app.File_App_Doc else fa.File_App_Doc end)as File_App_Doc,
 fa.F_TypeId as F_TypeId,
0 as Forward_Emp_Id,
0 as Submit_Emp_Id,0 as Review_Emp_Id,0 as Reviewed_by_Emp_Id,
FORMAT(GetDate(), 'dd/MM/yyyy') as Approve_Date
,'' as Approval_Comments,
'' as forwarded_by
,'' updated_by 
 ,fa.[User ID] as applicant
 --,eapp.Emp_Full_Name as application_by
 ,lgapp.Login_Name,lgapp.Emp_ID as E_Id
 ,(case when lgapp.Login_Name like '%admin%' then 'admin' else eapp.Emp_Full_Name end)as application_by
 ,es.Scheme_ID
  ,isnull(qry.Rpt_Level,0)as Rpt_Level
  ,isnull(fa.File_Type_Number,'')as File_Type_Number
    --,isnull(app.File_Type_Name,'')as File_Type_Name--added by mansi 30-09-22
from T0080_File_Application fa
--left join V0080_File_App_Admin_Side app on app.File_App_Id=fa.File_App_Id
--left join T0080_File_Approval app on app.File_App_Id=fa.File_App_Id
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = fa.F_StatusId
--left join T0030_File_Status_Common as fapc on fapc.S_ID = app.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
left join T0011_LOGIN as lgapp on lgapp.Login_ID=fa.[User ID]
left join T0080_EMP_MASTER as eapp on eapp.Emp_ID = lgapp.Emp_ID
inner join T0095_EMP_SCHEME es on es.Emp_ID=fa.Emp_ID and type='File Management' --added	
    and es.Effective_Date=(select max(Effective_Date) from T0095_EMP_SCHEME where type='File Management' and Emp_Id=es.Emp_ID )
left join	( SELECT MAX(Rpt_Level) AS Rpt_Level, File_App_Id 
		FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)  GROUP BY File_App_Id
						) AS Qry ON 
						Qry.File_App_Id = fa.File_App_Id 
