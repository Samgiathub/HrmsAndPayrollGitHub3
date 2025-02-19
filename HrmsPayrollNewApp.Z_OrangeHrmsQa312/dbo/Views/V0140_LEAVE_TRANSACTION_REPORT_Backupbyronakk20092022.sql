



Create VIEW [dbo].[V0140_LEAVE_TRANSACTION_REPORT_Backupbyronakk20092022]
AS
	SELECT TOP (100) PERCENT l.Cmp_ID, e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name,
	c.Cat_Name, de.Desig_Name, l.Leave_ID, dbo.T0040_LEAVE_MASTER.Leave_Name,
	l.For_Date
	, l.Leave_Opening, l.Leave_Credit, l.Leave_Used,
	l.Leave_Closing, l.Leave_Posting, l.Leave_Adj_L_Mark, l.CompOff_Credit, l.CompOff_Debit, l.CompOff_Balance, l.CompOff_Used,
	l.Back_Dated_Leave,l.Half_Payment_Days
	FROM dbo.T0140_LEAVE_TRANSACTION AS l WITH (NOLOCK) INNER JOIN

	dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID INNER JOIN
	dbo.T0040_GRADE_MASTER AS g WITH (NOLOCK)  ON e.Grd_ID = g.Grd_ID INNER JOIN
	dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON l.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID LEFT OUTER JOIN
	dbo.T0040_DESIGNATION_MASTER AS de WITH (NOLOCK)  ON e.Desig_Id = de.Desig_ID LEFT OUTER JOIN
	dbo.T0040_TYPE_MASTER AS t WITH (NOLOCK)  ON e.Type_ID = t.Type_ID LEFT OUTER JOIN
	dbo.T0030_CATEGORY_MASTER AS c WITH (NOLOCK)  ON e.Cat_ID = c.Cat_ID LEFT OUTER JOIN
	dbo.T0040_DEPARTMENT_MASTER AS d WITH (NOLOCK)  ON e.Dept_ID = d.Dept_Id
	
		WHERE	(l.Leave_Opening <> 0) OR
		(l.Leave_Credit <> 0) OR
		(l.Leave_Used <> 0) OR
		(l.Leave_Closing <> 0) OR
		(l.CompOff_Balance <> 0) OR
		(l.CompOff_Credit <> 0) OR
		(l.CompOff_Debit <> 0) OR
		(l.CompOff_Used <> 0)
		ORDER BY e.Emp_Full_Name, l.For_Date
