






CREATE VIEW [dbo].[V0110_Dependent_Detail_BACKUP_MEHUL_12042022]
AS
SELECT     EM.Emp_ID, EM.Cmp_ID, EM.Alpha_Emp_Code, EM.Branch_ID, BM.Branch_Name, GM.Grd_Name as Grade, DM.Desig_Name as Designation, Qry.Basic_Salary, Qry.Gross_Salary,
                      EM.Initial + '  ' + EM.Emp_First_Name + '  ' + ISNULL(EM.EMP_SECOND_NAME,'') + '  ' + EM.Emp_Last_Name AS Emp_Name, Convert (varchar(11),EM.Date_Of_Join,103) AS Date_Of_Join, 
                      EC.Name AS Dependent_Name, EC.Gender, EM.Father_name as Father_name, Convert (varchar(11),EC.Date_Of_Birth,103) AS Date_Of_Birth, EC.C_Age AS Dependent_Age, 
                      EC.Relationship, CASE EC.Is_Dependant WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS Is_Dependant, 
                      Case EM.Marital_Status When 0 Then 'Single' When 1 Then 'Married' When 2 Then 'Divorced' When 3 THEN 'Separated' When 4 Then 'Widowed' End As Marrital_Status,
					  ISNULL(EC.Height,'') AS Height,ISNULL(EC.Weight,'') AS Weight
FROM         dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) INNER JOIN

			(Select	I.Increment_ID,I.Branch_ID,I.Grd_ID,I.Desig_Id,I.Basic_Salary,I.Gross_Salary, I.Emp_ID
			From	T0095_INCREMENT I  WITH (NOLOCK) 
					INNER JOIN ( 
								Select	MAX(Increment_ID) As Increment_ID, I1.Emp_ID
								From	T0095_INCREMENT I1 WITH (NOLOCK) 
										INNER JOIN (
													Select	MAX(Increment_Effective_Date) As Increment_Effective_Date,I2.Emp_ID
													From	T0095_INCREMENT I2 WITH (NOLOCK) 
													WHERE Increment_Effective_Date <= Getdate()
													GROUP BY I2.Emp_ID
													) I2 ON I1.Increment_Effective_Date=I2.Increment_Effective_Date And I1.Emp_ID = I2.Emp_ID
								GROUP By I1.Emp_ID) I3 ON I.Increment_ID=I3.Increment_ID) Qry On EM.Emp_ID = Qry.Emp_ID Inner Join
                      dbo.T0090_EMP_CHILDRAN_DETAIL AS EC WITH (NOLOCK)  ON EM.Emp_ID = EC.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON Qry.Branch_ID = BM.Branch_ID INNER JOIN
                      dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  On Qry.Grd_ID = GM.Grd_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  On Qry.Desig_Id = DM.Desig_ID
                      



