



CREATE View [dbo].[V0080_File_Max_R_Level_Approve]
As

select distinct es.Scheme_ID,app.Rpt_Level,app.Tran_Id,fa.File_App_Id as FA_Id,
(cast(isnull(app.File_Apr_Id,0)as varchar)+'$'+cast(fa.File_App_Id as varchar)) as Id,
isnull(app.File_Apr_Id,0)as File_Apr_Id,app.File_App_Id,fa.Emp_ID,em.Alpha_Emp_Code,
em.Emp_Full_Name,EMSUP.Emp_Full_Name as Reporting_Manager,
format(fa.Application_Date,'dd/MM/yyyy') as Application_Date,
bm.Branch_Name,dm.Dept_Name,ds.Desig_Name,
app.F_StatusId as F_StatusId,
--fs.StatusTitle as ApplicationStatus,
fapc.S_Name as Status,
ft.TypeTitle,fa.File_Number,
app.Subject as Subject,
app.Description as Description,
format(app.Process_Date,'dd/MM/yyyy') as Process_Date,
fa.Branch_Id,fa.Dept_Id,fa.Desig_Id,fa.S_Emp_Id,fa.Cmp_ID,
 app.File_App_Doc as File_App_Doc,
--(case when File_Apr_Id<>0 then app.File_App_Doc else fa.File_App_Doc end)as File_App_Doc,
app.F_TypeId as F_TypeId,
isnull(app.Forward_Emp_Id,0)as Forward_Emp_Id,
isnull(app.Submit_Emp_Id,0)as Submit_Emp_Id,
FORMAT(IsNull(app.Approve_Date,GetDate()), 'dd/MM/yyyy') as Approve_Date
,isnull(Approval_Comments,'')as Approval_Comments,
isnull(app.Review_Emp_Id,0)as Review_Emp_Id,
isnull(app.Reviewed_by_Emp_Id,0)as Reviewed_by_Emp_Id,--added
--(case when app.Forward_Emp_Id<>0 then eg.Emp_Full_Name else '' end) as forwarded_by,
  lg.Login_Name,
  (case when Login_Name like '%admin%' then 'admin' else eg.Emp_Full_Name end)as updated_by 
 ,fa.[User ID] as applicant

--isnull(format(app.Approve_Date,'dd/MM/yyyy'),'')as Approve_Date
				--added 1 july start
			  ,efw.Emp_Full_Name as Forward_Employee
			  ,efwby.Emp_Full_Name as Forward_by_Employee,erw.Emp_Full_Name as Review_Employee,
			   erwby.Emp_Full_Name as Review_by_Employee
			    --added 1 july end
			,isnull(fa.File_Type_Number,'')as File_Type_Number--added by mansi 18-08-22
			 -- ,isnull(vapp.File_Type_Name,'')as File_Type_Name--added by mansi 30-09-22
--from T0080_File_Approval app
from T0115_File_Level_Approval app
left join T0080_File_Application fa  on app.File_App_Id=fa.File_App_Id
--left join V0080_File_App_Admin_Side vapp on vapp.File_App_Id=fa.File_App_Id--added by mansi 30-09-22

inner join  T0095_EMP_SCHEME  es on  es.emp_id=fa.emp_id and es.Cmp_ID=fa.Cmp_ID and type='File Management'
    and es.Effective_Date=(select max(Effective_Date) from T0095_EMP_SCHEME where type='File Management' and Emp_Id=es.Emp_ID )--added by mansi 30-09-22
left join T0080_EMP_MASTER as em on em.Emp_ID = fa.Emp_ID
left join T0080_EMP_MASTER as EMSUP on EMSUP.Emp_ID = fa.S_Emp_Id
left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = fa.Branch_ID
left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = fa.Dept_Id
left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = fa.Desig_ID
left join T0030_File_Status_Common as fapc on fapc.S_ID = app.F_StatusId
--left join T0040_File_Status_Master as fs on fs.F_StatusID = fa.F_StatusId
left join T0040_File_Type_Master as ft on ft.F_TypeID = fa.F_TypeID
left join T0011_LOGIN as lg on lg.Login_ID=app.[User ID]
left join T0080_EMP_MASTER as eg on eg.Emp_ID = lg.Emp_ID
--added on 1 july start
					left  join T0080_EMP_MASTER efw on efw.Emp_ID=app.Forward_Emp_Id
					left  join T0080_EMP_MASTER efwby on efwby.Emp_ID=app.Submit_Emp_Id
					left  join T0080_EMP_MASTER erw on erw.Emp_ID=app.Review_Emp_Id
					left  join T0080_EMP_MASTER erwby on erwby.Emp_ID=app.Reviewed_by_Emp_Id
					
				--added on 1 july end

where --app.F_StatusId in(2,3,5) and --added
app.Rpt_Level=(select max(rpt_level) from  T0050_Scheme_Detail where Scheme_Id=es.Scheme_ID)
