





CREATE VIEW [dbo].[V0120_LEAVE_APPROVAL_BACKUP_MEHUL_29112022]
AS
SELECT     LAD.From_Date, LAD.To_Date, LAD.Leave_Assign_As, LAD.Leave_Period, LAD.Leave_Approval_ID, LA.Approval_Status, 
			EM.Emp_First_Name, LA.Approval_Date, LAP.Application_Code, LAD.Cmp_ID, LAP.Application_Date, LM.Leave_Name, 
			LM.Leave_Paid_Unpaid, LM.Leave_Min, LM.Leave_Max, LM.Leave_Status, LM.Leave_Applicable, LM.Leave_Notice_Period, 
			LA.Leave_Application_ID, LM.Leave_ID, LAD.Leave_Reason, LAD.Row_ID, EM.Emp_Full_Name, I.Grd_ID, I.Dept_ID, 
			EM.Date_Of_Join, EM.Emp_code, EM.Other_Email, EM.Mobile_No, EM.Emp_ID, isnull(EMS.Emp_Full_Name,'Admin') AS S_emp_Full_Name,
			EMS.Other_Email AS S_Other_Email, LA.S_Emp_ID,LA.Approval_Comments, I.Branch_ID, I.Desig_Id, LM.Leave_Type, EM.Alpha_Emp_Code, 
            ISNULL(LAD.M_Cancel_WO_HO, 0) AS M_Cancel_WO_HO, LAD.Half_Leave_Date, LAD.Leave_CompOff_Dates, LM.Default_Short_Name, 
			EM.Work_Email, LM.Max_No_Of_Application, LM.Apply_Hourly,I.Vertical_ID,I.SubVertical_ID,   --Added By Jaina 22-09-2015
			LAPD.Leave_App_Doc,EMS.Emp_Full_Name AS  Senior_Employee,CASE LA.Is_Backdated_App WHEN 1 THEN '*' ELSE ''END as Is_Backdated_Application,T.Salary_Status,   --Added By Jaina 05-08-2016
            (
				SELECT STUFF((select '; ' + cast(convert(varchar(11),For_date,103) as varchar(max)) + '-' + cast(Leave_period as varchar(10))
					FROM T0150_LEAVE_CANCELLATION   T WITH (NOLOCK)
					WHERE T.Leave_Approval_id=LAD.Leave_Approval_ID
						AND T.Is_Approve=1
					ORDER BY EMP_ID
				FOR XML PATH('')), 1, 1, '') 
      
			) AS CANCEL_DATE,LAD.Leave_out_time,LAD.Leave_In_Time,LAD.Half_Payment,LA.Is_Backdated_App,LAD.Rules_violate,
			ER.Alpha_Emp_Code + ' - ' + ER.Emp_Full_Name As Responsible_Employee,I.SalDate_id , case when Is_Backdated_App = 1 then 1 else 0 end as Back_Dated_Leave,
			Responsible_Emp_id,1 AS 'is_Final_Approved',Branch_Name
FROM	dbo.T0080_EMP_MASTER AS EM  WITH (NOLOCK)
		INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID=I.EMP_ID
		INNER JOIN (SELECT	I1.Emp_ID, Max(I1.Increment_ID) As Increment_ID
					FROM	dbo.T0095_INCREMENT I1  WITH (NOLOCK)
							INNER JOIN (SELECT	I2.Emp_ID, Max(I2.Increment_Effective_Date) As Increment_Effective_Date
										FROM	dbo.T0095_INCREMENT I2 WITH (NOLOCK)
										WHERE	I2.Increment_Effective_Date <= GETDATE()
										GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
					GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID                      
		INNER JOIN	dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON EM.Emp_ID=LA.Emp_ID
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) ON LA.S_Emp_ID = EMS.Emp_ID AND LA.S_Emp_ID = EMS.Emp_ID 
		Left outer join dbo.T0030_BRANCH_MASTER Bm WITH (NOLOCK) ON BM.Branch_ID = I.Branch_ID
		LEFT OUTER JOIN dbo.T0100_LEAVE_APPLICATION LAP WITH (NOLOCK) ON LA.Leave_Application_ID = LAP.Leave_Application_ID 		
		LEFT OUTER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
		LEFT OUTER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID=LM.Leave_ID
		LEFT OUTER JOIN (SELECT	Leave_Application_ID, Leave_App_Doc 
						 FROM	T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK) 
						 WHERE	LEAVE_APP_DOC <> '' 
						 GROUP BY Leave_Application_ID, Leave_App_Doc) LAPD ON LAP.Leave_Application_ID=LAPD.Leave_Application_ID	
		LEFT OUTER JOIN (SELECT LAD.Leave_Approval_ID, lad.From_Date, LAD.To_Date, MIN(SAL.Month_St_Date) Month_St_Date, Min(SAL.Month_End_Date) Month_End_Date,Min(SAL.Salary_Status) Salary_Status
						 FROM	T0130_LEAVE_APPROVAL_DETAIL LAD  WITH (NOLOCK)
								INNER JOIN T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) ON lad.Leave_Approval_ID=LA1.Leave_Approval_ID
								INNER JOIN T0200_MONTHLY_SALARY SAL WITH (NOLOCK) ON ((lad.From_Date BETWEEN SAL.Month_St_Date AND SAL.Month_End_Date) OR (lad.To_Date BETWEEN SAL.Month_St_Date AND SAL.Month_End_Date)) AND LA1.Emp_ID=SAL.Emp_ID
						GROUP BY LAD.Leave_Approval_ID, lad.From_Date, LAD.To_Date
						  ) T ON LA.Leave_Approval_ID=T.Leave_Approval_ID 	 
		LEFT OUTER JOIN T0080_EMP_MASTER ER WITH (NOLOCK) ON ER.Emp_ID = LAP.Responsible_Emp_id




