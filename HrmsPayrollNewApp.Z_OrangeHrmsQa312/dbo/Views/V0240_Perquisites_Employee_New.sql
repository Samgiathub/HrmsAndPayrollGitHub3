


CREATE VIEW [dbo].[V0240_Perquisites_Employee_New]
AS
SELECT T.*,B.Branch_ID,b.Vertical_ID,B.SubVertical_ID,B.Dept_ID FROM
	(
			SELECT     Emp_id, Financial_Year, Emp_Name, Alpha_Emp_Code, Cmp_id 
			FROM         (SELECT DISTINCT Emp_id, Financial_Year, Emp_Name, Alpha_Emp_Code, Cmp_id
								   FROM          (SELECT     TOP (100) PERCENT dbo.T0240_Perquisites_Employee.Cmp_id, dbo.T0240_Perquisites_Employee.Emp_id, 
																				  dbo.T0240_Perquisites_Employee.Financial_Year, dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Name, 
																				  dbo.T0080_EMP_MASTER.Alpha_Emp_Code
														   FROM          dbo.T0240_Perquisites_Employee WITH (NOLOCK) INNER JOIN
																				  dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0240_Perquisites_Employee.Emp_id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
																				  dbo.T0240_Perquisites_Master WITH (NOLOCK)  ON 
																				  dbo.T0240_Perquisites_Employee.Perquisites_id = dbo.T0240_Perquisites_Master.Perquisites_Id
														   UNION
														   SELECT     TOP (100) PERCENT dbo.T0240_Perquisites_Employee_Car.cmp_id, dbo.T0240_Perquisites_Employee_Car.emp_id, 
																				 dbo.T0240_Perquisites_Employee_Car.Financial_Year, T0080_EMP_MASTER_1.Emp_Full_Name AS Emp_Name, 
																				 T0080_EMP_MASTER_1.Alpha_Emp_Code
														   FROM         dbo.T0240_Perquisites_Employee_Car WITH (NOLOCK)  INNER JOIN
																				 dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON 
																				 dbo.T0240_Perquisites_Employee_Car.emp_id = T0080_EMP_MASTER_1.Emp_ID INNER JOIN
																				 dbo.T0240_Perquisites_Master AS T0240_Perquisites_Master_1 WITH (NOLOCK)  ON 
																				 dbo.T0240_Perquisites_Employee_Car.perquisites_id = T0240_Perquisites_Master_1.Perquisites_Id
														   UNION
														   SELECT     TOP (100) PERCENT dbo.T0240_Perquisites_Employee_Dynamic.Cmp_id, dbo.T0240_Perquisites_Employee_Dynamic.Emp_id, 
																				 dbo.T0240_Perquisites_Employee_Dynamic.Financial_Year, T0080_EMP_MASTER_1.Emp_Full_Name AS Emp_Name, 
																				 T0080_EMP_MASTER_1.Alpha_Emp_Code
														   FROM         dbo.T0240_Perquisites_Employee_Dynamic WITH (NOLOCK)  INNER JOIN
																				 dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON 
																				 dbo.T0240_Perquisites_Employee_Dynamic.Emp_id = T0080_EMP_MASTER_1.Emp_ID
															
																				 
														   UNION
														   SELECT     TOP (100) PERCENT dbo.T0240_PERQUISITES_EMPLOYEE_GEW.Cmp_id, dbo.T0240_PERQUISITES_EMPLOYEE_GEW.Emp_id, 
																				 dbo.T0240_PERQUISITES_EMPLOYEE_GEW.Financial_Year, T0080_EMP_MASTER_1.Emp_Full_Name AS Emp_Name, 
																				 T0080_EMP_MASTER_1.Alpha_Emp_Code
														   FROM         dbo.T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK)  INNER JOIN
																				 dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON 
																				 dbo.T0240_PERQUISITES_EMPLOYEE_GEW.Emp_id = T0080_EMP_MASTER_1.Emp_ID) AS Qry) AS Qry1
	) T LEFT OUTER JOIN --Added By Jaina 08-09-2015 Start
	(
		SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID 
						FROM	T0095_INCREMENT I WITH (NOLOCK) 
						WHERE	I.INCREMENT_ID = (
													SELECT	TOP 1 INCREMENT_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
													WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
													ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
												)
	) AS B ON B.EMP_ID = T.EMP_ID AND B.CMP_ID=T.CMP_ID 
	--Added By Jaina 08-09-2015 End                                                                     
--ORDER BY RIGHT(REPLICATE(N' ', 500) + Alpha_Emp_Code, 500)




