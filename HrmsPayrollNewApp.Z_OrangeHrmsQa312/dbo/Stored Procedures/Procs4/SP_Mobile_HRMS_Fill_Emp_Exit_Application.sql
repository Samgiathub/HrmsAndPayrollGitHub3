

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_Fill_Emp_Exit_Application] 
	@Rpt_level	numeric(18,0)
   ,@Exit_Id numeric(18,0)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @RPT_LEVEL = 1 
	BEGIN
		
		Select distinct exit_id,emp_id,cmp_id,branch_id,desig_id,convert(varchar,resignation_date,23),
					convert(varchar,last_date,23),reason,comments,status,is_rehirable,
					feedback,sup_ack,convert(varchar,interview_date,23),
					interview_time,Is_process,Email_ForwardTo,DriveData_ForwardTo,Emp_Full_Name,
					Application_date,'' as Approval_date,
					Branch_Name,Desig_Name,Alpha_Emp_Code,Exit_App_Doc -- EXIT_APP_DOC ADDED BY RAJPUT ON 14052018
		from V0200_Emp_ExitApplication where exit_id = @Exit_id
	END
ELSE
	BEGIN
		Select distinct VE.exit_id,VE.emp_id,VE.cmp_id,VE.branch_id,VE.desig_id,VE.Emp_Full_Name,VE.Alpha_Emp_Code,VE.Branch_Name,VE.Desig_Name,
					isnull(CONVERT(VARCHAR,Qry1.resignation_date,23),CONVERT(VARCHAR,VE.resignation_date,23)) AS resignation_date,
					isnull(CONVERT(VARCHAR,Qry1.last_date,23),CONVERT(VARCHAR,VE.last_date,23)) AS last_date,
					isnull(Qry1.reason,VE.reason) As reason,
					isnull(Qry1.comments,VE.comments) As comments,
					isnull(Qry1.status,VE.status) as status,
					isnull(Qry1.is_rehirable,VE.is_rehirable) as is_rehirable,
					isnull(Qry1.feedback,VE.feedback) as feedback,
					isnull(Qry1.sup_ack,VE.sup_ack) as sup_ack,
					isnull(CONVERT(VARCHAR,Qry1.interview_date,23),CONVERT(VARCHAR,VE.interview_date,23)) as interview_date,
				 	isnull(Qry1.interview_time,VE.interview_time) as interview_time,
					isnull(Qry1.Is_process,VE.Is_process) as Is_process,
					isnull(Qry1.Email_ForwardTo,VE.Email_ForwardTo) as Email_ForwardTo,
					isnull(Qry1.DriveData_ForwardTo,VE.DriveData_ForwardTo) as DriveData_ForwardTo,
					ISNULL(CONVERT(VARCHAR,Qry1.Application_date,23),CONVERT(VARCHAR,VE.Application_date,23)) As Application_date,  --Added By Jaina 11-05-2016
					ISNULL(CONVERT(VARCHAR,Qry1.Approval_Date,23),'') As Approval_Date,  --Added By Jaina 11-05-2016					
					VE.EXIT_APP_DOC -- EXIT_APP_DOC FOR DOCUMENTS ADDED BY RAJPUT ON 14052018
				   From V0200_Emp_ExitApplication VE left outer join 
				   (
					   select EL.Exit_id As App_ID, Rpt_Level  as Rpt_Level,convert(varchar,EL.Resignation_date,103) as Resignation_date,
					   convert(varchar, EL.Last_date,103) as Last_date,
					   EL.Reason,EL.Comments,EL.Status,(case when EL.Is_rehirable = 0 then 'N' Else 'Y' end) as is_rehirable,EL.S_Emp_Id,EL.Feedback,
					   EL.Sup_ack,EL.Interview_date,EL.Interview_time,EL.Is_Process,EL.Email_ForwardTo,EL.DriveData_ForwardTo,
					   convert(varchar,EL.Application_date,103) as Application_date,
					   convert(varchar,EL.Approval_Date,103) as Approval_Date
					   From T0300_Emp_Exit_Approval_Level EL WITH (NOLOCK) inner join 
					   (
						Select max(RPT_Level) as RPT_Level1,Exit_id From T0300_Emp_Exit_Approval_Level WITH (NOLOCK)
						where Exit_id = @Exit_ID Group by Exit_id
					   ) Qry on qry.Exit_id = EL.Exit_id and qry.RPT_Level1 = EL.RPT_Level
				   ) As Qry1 On  VE.Exit_id = Qry1.App_ID	
				   where VE.Exit_id = @Exit_ID
	END
	
END


