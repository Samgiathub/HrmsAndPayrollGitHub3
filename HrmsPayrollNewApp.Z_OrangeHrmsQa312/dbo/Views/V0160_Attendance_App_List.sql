


CREATE VIEW [dbo].[V0160_Attendance_App_List]
AS

WITH Manager_CTE(Emp_ID, Effect_Date, R_Emp_ID) AS 
(
 SELECT ERD.Emp_ID, ERD.Effect_Date, ERD.R_Emp_ID
   FROM dbo.T0090_EMP_REPORTING_DETAIL AS ERD WITH (NOLOCK)
 INNER JOIN
		(
			SELECT MAX(Effect_Date) AS Eff_Date, Emp_ID
				FROM dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
            WHERE (Effect_Date < GETDATE())
			GROUP BY Emp_ID
		) AS Qry ON ERD.Emp_ID = Qry.Emp_ID AND ERD.Effect_Date = Qry.Eff_Date
)
    
	SELECT  CT.Emp_ID, CT.Effect_Date, CT.R_Emp_ID, AA.Att_App_ID, AA.Cmp_ID,
			AA.For_Date, AA.Shift_Sec, AA.P_Days,EM.Alpha_Emp_Code,EM.Emp_Full_Name,0 as Att_Apr_ID,'New Application' as Status,'' as Remarks
    FROM Manager_CTE AS CT  
	INNER JOIN dbo.T0160_Attendance_Application AS AA  WITH (NOLOCK)
	ON CT.Emp_ID = AA.Emp_ID
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = AA.EMP_ID 
	WHERE NOT EXISTS(Select 1 From T0165_Attendance_Approval WITH (NOLOCK) Where Att_App_ID = AA.Att_App_ID)

