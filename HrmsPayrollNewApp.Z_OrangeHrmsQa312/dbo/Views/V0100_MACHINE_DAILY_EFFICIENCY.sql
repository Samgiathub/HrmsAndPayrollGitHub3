




CREATE VIEW [dbo].[V0100_MACHINE_DAILY_EFFICIENCY]
AS
SELECT	MDE.Efficiency_ID,EM.Emp_ID,MDE.Cmp_ID, MDE.For_Date,MDE.Machine_ID,MDE.Shift_ID,
		MDE.Efficiency,TY.Machine_Name,TY.Machine_Type,
		EM.Alpha_Emp_code AS Assigned_EmpCode, EM.Emp_Full_Name AS Assigned_EmpName , (EM.Alpha_Emp_code + ' - ' + EM.Emp_Full_Name) AS Assigned_EmpFullName,
		EM1.Emp_ID AS Alternate_EmpID, EM1.Alpha_Emp_Code AS Alternate_EmpCode,EM1.Emp_Full_Name AS Alternate_EmpName , (EM1.Alpha_Emp_code + ' - ' + EM1.Emp_Full_Name) AS Alternate_EmpFullName,
		BS.MachineEmpType AS WeavingFlag ,SM.Shift_Name , MDE.Segment_ID
FROM	T0100_MACHINE_DAILY_EFFICIENCY MDE WITH (NOLOCK)
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Cmp_ID = MDE.Cmp_ID AND EM.Emp_ID = MDE.Assigned_Emp_ID
		INNER JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON EM.Cmp_ID = MDE.Cmp_ID AND EM1.Emp_ID = MDE.Alternate_Emp_ID
		INNER JOIN T0040_BUSINESS_SEGMENT BS WITH (NOLOCK) ON BS.Cmp_ID = MDE.Cmp_ID AND BS.Segment_ID = MDE.Segment_ID
		INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Cmp_ID = MDE.Cmp_ID AND SM.Shift_ID = MDE.Shift_ID
		CROSS APPLY (SELECT STUFF((SELECT	',' + MM.Machine_Name
								   FROM		T0040_Machine_Master MM WITH (NOLOCK)
								   WHERE	CHARINDEX('#' + CAST(MM.Machine_ID AS VARCHAR(10)) + '#', '#' + MDE.Machine_ID + '#') > 0
											FOR XML PATH('')), 1,1,'') AS Machine_Name,
							STUFF((SELECT	DISTINCT ',' + MM.Machine_Type
								   FROM		T0040_Machine_Master MM WITH (NOLOCK)
								   WHERE	CHARINDEX('#' + CAST(MM.Machine_ID AS VARCHAR(10)) + '#', '#' + MDE.Machine_ID + '#') > 0
											FOR XML PATH('')), 1,1,'') AS Machine_Type
					 ) TY




