



CREATE VIEW [dbo].[V0300_Emp_Exit_Approval_Level]
AS
SELECT     EL.Tran_Id,EL.Exit_id,EL.Emp_id,EL.Cmp_id,EL.Branch_id,EL.Desig_id,EL.Resignation_date,EL.Last_date,
		   EL.Reason,EL.Comments,EL.Status,EL.Is_rehirable,EL.S_Emp_Id,EL.Feedback,EL.Sup_ack,
		   EL.Interview_date,EL.Interview_time,EL.Is_Process,EL.Email_ForwardTo,EL.DriveData_ForwardTo,
		   EL.RPT_Level,EL.Final_Approval,EL.Is_FWD_REJECT,
		   E.Alpha_Emp_Code,E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name As Emp_Full_Name,EL.Approval_date
FROM         dbo.T0300_Emp_Exit_Approval_Level  EL WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER  E WITH (NOLOCK)  ON EL.Emp_ID = E.Emp_ID


