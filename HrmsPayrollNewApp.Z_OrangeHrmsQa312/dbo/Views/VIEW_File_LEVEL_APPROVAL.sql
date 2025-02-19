


CREATE VIEW [dbo].[VIEW_File_LEVEL_APPROVAL]
AS
               SELECT  (case when GP.File_Apr_Id<>0 then 1 else 0 end) as Final_Approver,GP.File_Apr_Id as FA_Id,gp.Emp_Id as Emp_ID,gp.Cmp_Id,gp.Tran_Id,GP.File_App_Id, GP.S_emp_ID, GP.F_StatusId as APR_Status,
			  gp.Approve_Date,gp.File_Apr_Id,
			  gp.File_Number,isnull(gp.Subject,'')as Subject,isnull(gp.Description,'')as Description,
			  gp.F_StatusId,gp.Process_Date
			  --,gp.File_App_Doc
			  ,isnull(stuff(gp.file_App_Doc, 1, charindex('#', gp.file_App_Doc), '') ,'')as File_App_Doc--added on 27-04-22
			 -- ,isnull(right(gp.File_App_Doc, len(gp.File_App_Doc) - 17),'')as File_App_Doc
			  ,gp.Forward_Emp_Id,gp.Submit_Emp_Id
			  ,GP.Approval_Comments,GP.Rpt_Level,fsc.S_Name as Status
			 -- ,lg.Emp_ID as UpdatedEmp --added
			 ,la.Application_Date,la.Alpha_Emp_Code,la.Emp_First_Name,la.Emp_Full_Name
			  ,es.Scheme_ID--added
			  ,lg.Emp_ID as updatedbyEmp
			  ,gp.Review_Emp_Id,gp.Reviewed_by_Emp_Id
			  --added 1 july start
			    ,efw.Emp_Full_Name as Forward_Employee
			  ,efwby.Emp_Full_Name as Forward_by_Employee,erw.Emp_Full_Name as Review_Employee,
			   erwby.Emp_Full_Name as Review_by_Employee
			   --added 1 july end
			   ,isnull(gp.File_Type_Number,'')as File_Type_Number--added by mansi 23-08-22
                FROM   dbo.T0115_File_Level_Approval AS GP WITH (NOLOCK) 
					
				 --inner join T0095_EMP_SCHEME es on es.Emp_ID=GP.Emp_ID--added
					INNER JOIN
						( SELECT MAX(Rpt_Level) AS Rpt_Level, File_App_Id FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)  GROUP BY File_App_Id--,File_Apr_Id
						) AS Qry ON Qry.Rpt_Level = GP.Rpt_Level AND Qry.File_App_Id = GP.File_App_Id 
					INNER JOIN dbo.V0080_File_App_Admin_Side AS LA WITH (NOLOCK)  ON LA.File_App_Id = GP.File_App_Id
					left join T0030_File_Status_Common as fsc on fsc.S_ID = GP.F_StatusId
					inner join T0011_LOGIN lg on lg.Login_ID=gp.[User ID]
				--left outer JOIN T0115_File_Level_Approval GPR WITH (NOLOCK)  ON gp.File_App_Id =GPR.File_App_Id
			  	inner join T0095_EMP_SCHEME es on es.Emp_ID=GP.Emp_ID and type='File Management' --added		
					 --added 1 july start
					left  join T0080_EMP_MASTER efw on efw.Emp_ID=gp.Forward_Emp_Id
					left  join T0080_EMP_MASTER efwby on efwby.Emp_ID=gp.Submit_Emp_Id
					left  join T0080_EMP_MASTER erw on erw.Emp_ID=gp.Review_Emp_Id
					left  join T0080_EMP_MASTER erwby on erwby.Emp_ID=gp.Reviewed_by_Emp_Id	
				 --added 1 july end
				WHERE    GP.F_StatusId  in(2,3,4,5) 
