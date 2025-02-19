


CREATE VIEW [dbo].[VIEW_File_FINAL_N_LEVEL_APPROVAL_backup_28_04_22]
AS
SELECT   distinct GPA.Cmp_ID, GPA.File_App_Id, GPA.Emp_ID,gpa.Application_Date
  --format(gpa.Application_Date,'dd/MM/yyyy') as Application_Date
   ,ISNULL(GPR.File_Apr_Id,0) AS FA_Id,  GPA.Alpha_Emp_Code, GPA.Emp_Full_Name,GPA.Emp_First_Name,
   gpa.File_Number,
   isnull(qry.Subject,'')as Subject,
    isnull(qry.Description,'')as Description,GPA.F_TypeId,qry.APR_Status,qry.Status,
       qry.Forward_Emp_Id,qry.Submit_Emp_Id,

		 -- dbo.F_GET_AMPM(qry.From_Time) AS From_Time,dbo.F_GET_AMPM(qry.To_Time) AS To_Time,
		
		  qry.S_emp_ID AS S_Emp_ID_A,qry.S_emp_ID,qry.APR_Status as F_StatusId,
           qry.Rpt_Level AS Rpt_Level,qry.Approval_Comments AS Approval_Comments
		   ,GPR.Tran_Id
		  	,es.Scheme_ID--added
			,qry.UpdatedEmp as updatedbyEmp--added
			,qry.Review_Emp_Id,qry.Reviewed_by_Emp_Id
			--as File_App_Doc
			,isnull(stuff(qry.file_App_Doc, 1, charindex('#', qry.file_App_Doc), '') ,'')as File_App_Doc--added on 27-04-22
			--,isnull(right(qry.File_App_Doc, len(qry.File_App_Doc) - 17),'')as File_App_Doc--added
FROM      dbo.V0080_File_App_Admin_Side AS GPA WITH (NOLOCK) INNER JOIN
              ( SELECT  GP.File_App_Id, GP.S_emp_ID, GP.F_StatusId as APR_Status,
			  gp.Approve_Date,gp.File_Apr_Id,
			  gp.File_Number,isnull(gp.Subject,'')as Subject,isnull(gp.Description,'')as Description,
			  gp.F_StatusId,gp.Process_Date,gp.File_App_Doc,gp.Forward_Emp_Id,gp.Submit_Emp_Id
			  ,GP.Approval_Comments,GP.Rpt_Level,fsc.S_Name as Status
			  ,lg.Emp_ID as UpdatedEmp --added
			  ,gp.Review_Emp_Id,gp.Reviewed_by_Emp_Id--added
			 -- ,gp.File_App_Doc--added
			  --,es.Scheme_ID--added
                FROM   dbo.T0115_File_Level_Approval AS GP WITH (NOLOCK) 
					inner join T0011_LOGIN lg on lg.Login_ID=GP.[User ID]
				 --inner join T0095_EMP_SCHEME es on es.Emp_ID=GP.Emp_ID--added
					INNER JOIN
						( SELECT MAX(Rpt_Level) AS Rpt_Level, File_App_Id FROM dbo.T0115_File_Level_Approval WITH (NOLOCK)  GROUP BY File_App_Id
						) AS Qry ON Qry.Rpt_Level = GP.Rpt_Level AND Qry.File_App_Id = GP.File_App_Id 
					INNER JOIN dbo.V0080_File_App_Admin_Side AS LA WITH (NOLOCK)  ON LA.File_App_Id = GP.File_App_Id
					left join T0030_File_Status_Common as fsc on fsc.S_ID = GP.F_StatusId
				
					
				WHERE    GP.F_StatusId  in(2,3,4,5)
				--(GP.APR_Status <> 'A') OR (GP.APR_Status = 'R')
			  ) AS qry ON GPA.File_App_Id = qry.File_App_Id
	
			  left outer JOIN T0115_File_Level_Approval GPR WITH (NOLOCK)  ON GPA.File_App_Id =GPR.File_App_Id
			  	inner join T0095_EMP_SCHEME es on es.Emp_ID=GPR.Emp_ID and type='File Management' --added		

