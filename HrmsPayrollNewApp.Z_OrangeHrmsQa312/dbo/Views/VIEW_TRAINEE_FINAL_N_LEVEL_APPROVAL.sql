




CREATE VIEW [dbo].[VIEW_TRAINEE_FINAL_N_LEVEL_APPROVAL]
AS
SELECT  ET.Cmp_ID,ET.Emp_ID, ET.Emp_Full_Name, ET.Alpha_Emp_code, ET.Emp_first_name, ET.Branch_Name, ET.Branch_ID,
		ET.Date_Of_Join,
		CASE WHEN ISNULL(qry.probation_date,'') = '' THEN ET.probation_date ELSE qry.probation_date END AS Probation_Date,
		ISNULL(qry.rpt_level + 1,'1') AS Rpt_Level,ET.Desig_Id ,qry.S_Emp_ID AS S_Emp_ID_A,qry.Status AS Status
		,qry.Evaluation_Date,qry.Old_Probation_EndDate,qry.Tran_Id,probation_Status
		,0 As Scheme_Id,0 As Final_Approver,0 As Is_Fwd_Leave_Rej,ET.Training_Month,Review_Type,qry.Training_ID,qry.Approval_Period_Type,
		qry.Major_Strength,qry.Major_Weakness,qry.Appraiser_Remarks,qry.Appraisal_Reviewer_Remarks,ET.Desig_Name,
		ET.Dept_Name,ET.[Type_Name],qry.Extend_Period,qry.New_Probation_EndDate,ET.Dept_ID
FROM	dbo.V0080_EMP_TRAINEE_GET AS ET WITH (NOLOCK) INNER JOIN
		  ( SELECT  PT.Emp_id AS Emp_id, Qry.Rpt_Level AS Rpt_Level , PT.New_Probation_EndDate AS probation_date,pt.S_Emp_ID,PT.Status,Evaluation_Date,Old_Probation_EndDate,Tran_Id,probation_Status,
		  PT.Training_ID,PT.Approval_Period_Type,PT.Major_Strength,PT.Major_Weakness,PT.Appraiser_Remarks,PT.Appraisal_Reviewer_Remarks,pt.Review_Type,pt.Extend_Period,pt.New_Probation_EndDate
			FROM   dbo.T0115_EMP_PROBATION_MASTER_LEVEL AS PT  WITH (NOLOCK) 
				INNER JOIN
					( SELECT MAX(Rpt_Level) AS Rpt_Level, Emp_id 
					  FROM dbo.T0115_EMP_PROBATION_MASTER_LEVEL PT1  WITH (NOLOCK) WHERE FLAG = 'Trainee' 
					--  AND Probation_Evaluation_ID = 0
					  GROUP BY Emp_id
					 ) AS Qry ON Qry.Rpt_Level = PT.Rpt_Level AND Qry.Emp_id = PT.Emp_id 
				INNER JOIN dbo.V0080_EMP_TRAINEE_GET AS LA WITH (NOLOCK)  ON LA.Emp_id = PT.Emp_id
			WHERE PT.FLAG = 'Trainee' AND  (PT.Status = 'A' OR PT.Status = 'R')
				--AND Probation_Evaluation_ID = 0
		  ) AS qry ON ET.Emp_ID = qry.Emp_ID




