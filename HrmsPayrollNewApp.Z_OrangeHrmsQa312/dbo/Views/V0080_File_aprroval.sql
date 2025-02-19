






CREATE View [dbo].[V0080_File_aprroval]
As

select distinct es.Scheme_ID,fa.File_App_Id as FA_Id,(cast(isnull(app.File_Apr_Id,0)as varchar)+'$'+cast(fa.File_App_Id as varchar)) as Id,
isnull(app.File_Apr_Id,0)as File_Apr_Id,fa.File_App_Id,fa.Emp_ID,em.Alpha_Emp_Code,
em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,
format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name,
(case when File_Apr_Id<>0 then app.F_StatusId else fa.F_StatusId end) as F_StatusId,
--fs.StatusTitle as ApplicationStatus,
(case when File_Apr_Id<>0 then fapc.S_Name else fsc.S_Name end)  as Status,
ft.TypeTitle,fa.File_Number,
(case when File_Apr_Id<>0 then app.Subject else fa.Subject end)as Subject,
(case when File_Apr_Id<>0 then app.Description else fa.Description end)as Description,
format(fa.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,
(case when app.File_App_Doc<>'' then app.File_App_Doc else fa.File_App_Doc end)as File_App_Doc,
--(case when File_Apr_Id<>0 then app.File_App_Doc else fa.File_App_Doc end)as File_App_Doc,
(case when File_Apr_Id<>0 then app.F_TypeId else fa.F_TypeId end)as F_TypeId,
isnull(app.Forward_Emp_Id,0)as Forward_Emp_Id,
isnull(app.Submit_Emp_Id,0)as Submit_Emp_Id,
FORMAT(IsNull(app.Approve_Date,GetDate()), 'dd/MM/yyyy') as Approve_Date
,isnull(Approval_Comments,'')as Approval_Comments,
isnull(app.Review_Emp_Id,0)as Review_Emp_Id,isnull(app.Reviewed_by_Emp_Id,0)as Reviewed_by_Emp_Id,--added
(case when app.Forward_Emp_Id<>0 then efwd.Emp_Full_Name else '' end) as forwarded_by
 , (case when app.F_StatusId>1 then efwd.Emp_Full_Name else '' end)updated_by 
 ,fa.[User ID] as applicant
 ,eapp.Emp_Full_Name as application_by
--isnull(format(app.Approve_Date,'dd/MM/yyyy'),'')as Approve_Date
,isnull(qry.Rpt_Level,0)as Rpt_Level
----added 1 july start
			 -- ,efw.Emp_Full_Name as Forward_Employee
			 -- ,efwby.Emp_Full_Name as Forward_by_Employee,erw.Emp_Full_Name as Review_Employee,
			 --  erwby.Emp_Full_Name as Review_by_Employee
			 ,'' as Forward_Employee
			 --   --added 1 july end
			 ,isnull(fa.File_Type_Number,'')as File_Type_Number ---added on 22-08-22
from T0080_File_Approval app
left join T0080_File_Application fa  on app.File_App_Id=fa.File_App_Id
inner join  T0095_EMP_SCHEME  es on  es.emp_id=fa.emp_id and es.Cmp_ID=fa.Cmp_ID and type='File Management'
 and es.Effective_Date=(select max(Effective_Date) from T0095_EMP_SCHEME where type='File Management' and Emp_Id=app.Emp_ID )
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fsc on fsc.S_ID = fa.F_StatusId
left join T0030_File_Status_Common as fapc on fapc.S_ID = app.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
left join T0011_LOGIN as lg on lg.Login_ID=app.[User ID]
left join T0080_EMP_MASTER as efwd on efwd.Emp_ID = lg.Emp_ID
left join T0011_LOGIN as lgapp on lgapp.Login_ID=fa.[User ID]
left join T0080_EMP_MASTER as eapp on eapp.Emp_ID = lgapp.Emp_ID
left join	( SELECT MAX(Rpt_Level) AS Rpt_Level, File_App_Id 
		FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)  GROUP BY File_App_Id
						) AS Qry ON 
						Qry.File_App_Id = app.File_App_Id 
						----added on 1 july start
				--	left  join T0080_EMP_MASTER efw on efw.Emp_ID=fa.Forward_Emp_Id
				--	left  join T0080_EMP_MASTER efwby on efwby.Emp_ID=fa.Submit_Emp_Id
				--	left  join T0080_EMP_MASTER erw on erw.Emp_ID=fa.Review_Emp_Id
				--	left  join T0080_EMP_MASTER erwby on erwby.Emp_ID=fa.Reviewed_by_Emp_Id					
				----added on 1 july end
