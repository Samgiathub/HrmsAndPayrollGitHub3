


create VIEW [dbo].[VIEW_File_Pending_Approve_backup_16_09_22]
AS
SELECT   distinct isnull(qry.Rpt_Level,0)as Rpt_Level,
ApplicationStatus,
gpa.Scheme_ID,gpa.File_App_Id,gpa.Emp_ID,Alpha_Emp_Code,
Emp_Full_Name,Reporting_Manager,
Application_Date,
Branch_Name,Dept_Name,Desig_Name,gpa.F_StatusId,Emp_First_Name,
 
TypeTitle,gpa.File_Number,gpa.Subject,gpa.Description,gpa.Process_Date,
Branch_Id,Dept_Id,Desig_Id,gpa.Cmp_ID,gpa.File_App_Doc,gpa.F_TypeId
,gpa.[User ID]
, RComments
, gpa.Review_Emp_Id
, Addedby 
, Updatedby 
	----added 1 july start
			 -- ,efw.Emp_Full_Name as Forward_Employee
			 -- ,efwby.Emp_Full_Name as Forward_by_Employee,erw.Emp_Full_Name as Review_Employee,
			 --  erwby.Emp_Full_Name as Review_by_Employee
			 ,'' as Forward_Employee
			 --   --added 1 july end
			 ,isnull(gpa.File_Type_Number,'')as File_Type_Number--added on 22-08-22
FROM      dbo.V0080_File_App_Admin_Side AS GPA WITH (NOLOCK) left JOIN
	( SELECT MAX(Rpt_Level) AS Rpt_Level, File_App_Id 
		FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)  GROUP BY File_App_Id
						) AS Qry ON 
						Qry.File_App_Id = gpa.File_App_Id 
			  -- and gpa.F_StatusId in(2,3,4,5) 
			   and gpa.File_App_Id not in(select File_App_Id from T0080_File_Approval where File_App_Id=gpa.File_App_Id )
			  
where  gpa.File_App_Id not in(select File_App_Id from T0080_File_Approval)
and isnull(qry.Rpt_Level,0)<>(select max(rpt_level) from  T0050_Scheme_Detail where Scheme_Id=gpa.Scheme_ID)
				----added on 1 july start
				--	left  join T0080_EMP_MASTER efw on efw.Emp_ID=fa.Forward_Emp_Id
				--	left  join T0080_EMP_MASTER efwby on efwby.Emp_ID=fa.Submit_Emp_Id
				--	left  join T0080_EMP_MASTER erw on erw.Emp_ID=fa.Review_Emp_Id
				--	left  join T0080_EMP_MASTER erwby on erwby.Emp_ID=fa.Reviewed_by_Emp_Id					
				----added on 1 july end
--order by gpa.File_App_Id
