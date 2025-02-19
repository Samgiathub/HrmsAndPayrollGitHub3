CREATE VIEW [DBO].[V9999_EMPLOYEE_DETAIL_DNL]
AS
SELECT Alpha_Emp_Code AS EMP_NO, Emp_Full_Name AS EMP_NAME, Gender, EM.Work_Email AS EMAIL_ID, '' AS SUPERVISOR_NO, Payment_Mode,
	BM.Bank_Code, BM.Bank_Name, INC.Bank_Branch_Name, INC.Inc_Bank_AC_No AS BANK_ACID, EM.Ifsc_Code AS BANK_IFSC, VS.Vertical_Name AS CATEGORY_CADER
FROM T0080_EMP_MASTER EM WITH (NOLOCK)
	INNER JOIN 
		(SELECT I.Emp_Id,i.Dept_ID,i.Center_ID,I.Bank_ID,I.Branch_ID, I.Vertical_ID,I.Payment_Mode,I.Bank_Branch_Name, I.Inc_Bank_AC_No
			FROM T0095_Increment I  WITH (NOLOCK)
			INNER JOIN (SELECT MAX(INCREMENT_ID) AS Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK)
						WHERE INCREMENT_EFFECTIVE_DATE <= GETDATE()
						GROUP BY EMP_ID) Qry on
			I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id) AS INC on INC.Emp_ID = EM.Emp_ID
	LEFT OUTER JOIN T0040_BANK_MASTER BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
	LEFT OUTER JOIN T0040_Vertical_Segment VS  WITH (NOLOCK) ON VS.Vertical_ID = INC.Vertical_ID

