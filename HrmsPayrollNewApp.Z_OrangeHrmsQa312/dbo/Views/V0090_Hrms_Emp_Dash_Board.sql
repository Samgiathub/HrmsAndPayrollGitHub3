





CREATE VIEW [dbo].[V0090_Hrms_Emp_Dash_Board]
AS
SELECT     Em.Grd_ID, Em.Dept_ID, Em.Desig_Id, HAI.Login_Id, L.Login_Name AS Initiatedby, HAID.Emp_Id, HAID.start_date, HAID.End_date, HAI.For_Date, 
                      HAI.Cmp_Id, HAI.Appr_Int_Id, HAID.Appr_Detail_Id, Em.Emp_Full_Name, Em.Emp_Superior, E.Emp_First_Name AS Emp_Sup_Name, Dm.Desig_Name, 
                      Em.Emp_code, Em.Emp_First_Name, Em.Branch_ID
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HAID WITH (NOLOCK) INNER JOIN
                      dbo.T0090_Hrms_Appraisal_Initiation AS HAI WITH (NOLOCK)  ON HAID.Appr_Int_Id = HAI.Appr_Int_Id INNER JOIN
                      dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK)  ON HAID.Emp_Id = Em.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON Em.Emp_Superior = E.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS Dm WITH (NOLOCK)  ON Em.Desig_Id = Dm.Desig_ID INNER JOIN
                      dbo.T0011_LOGIN AS L WITH (NOLOCK)  ON HAI.Login_Id = L.Login_ID




