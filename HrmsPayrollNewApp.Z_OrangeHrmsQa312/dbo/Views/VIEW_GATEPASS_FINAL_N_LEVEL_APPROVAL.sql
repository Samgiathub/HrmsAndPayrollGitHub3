





CREATE VIEW [dbo].[VIEW_GATEPASS_FINAL_N_LEVEL_APPROVAL]
AS
SELECT    GPA.Cmp_ID, GPA.App_ID, GPA.Emp_ID, GPA.APP_Date, GPA.For_Date,
		 -- dbo.F_GET_AMPM(qry.From_Time) AS From_Time,dbo.F_GET_AMPM(qry.To_Time) AS To_Time,
		 CONVERT(VARCHAR(5), qry.From_Time, 108 ) AS From_Time, CONVERT(VARCHAR(5), qry.To_Time, 108 ) AS To_Time,
		  qry.Duration,
          qry.APR_Status AS App_Status, qry.Reason_Name ,--GPA.Reason_Name,
          GPA.Alpha_Emp_Code, GPA.Emp_Full_Name,GPA.Emp_First_Name, qry.S_emp_ID AS S_Emp_ID_A
          ,ISNULL(GPR.Apr_ID,0) AS Apr_ID , qry.Rpt_Level AS Rpt_Level,GPA.Remarks AS Emp_Remarks
FROM      dbo.V0100_GATE_PASS_APPLICATION AS GPA WITH (NOLOCK) INNER JOIN
              ( SELECT  GP.App_ID, GP.S_emp_ID, GP.APR_Status,GP.From_Time,GP.To_Time,GP.Duration,GP.Apr_Remarks,GP.Rpt_Level,RM.Reason_Name
                FROM   dbo.T0115_GATE_PASS_LEVEL_APPROVAL AS GP WITH (NOLOCK) 
					INNER JOIN
						( SELECT MAX(Rpt_Level) AS Rpt_Level, App_ID FROM dbo.T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK)  GROUP BY App_ID) AS Qry ON Qry.Rpt_Level = GP.Rpt_Level AND Qry.App_ID = GP.App_ID 
					INNER JOIN dbo.V0100_GATE_PASS_APPLICATION AS LA WITH (NOLOCK)  ON LA.App_ID = GP.App_ID
					INNER JOIN dbo.T0040_Reason_Master RM WITH (NOLOCK)  ON RM.Res_Id = GP.Reason_ID
				WHERE     (GP.APR_Status = 'A') OR (GP.APR_Status = 'R')
			  ) AS qry ON GPA.App_ID = qry.App_ID LEFT OUTER JOIN T0120_GATE_PASS_APPROVAL GPR WITH (NOLOCK)  ON GPA.App_ID =GPR.App_ID




