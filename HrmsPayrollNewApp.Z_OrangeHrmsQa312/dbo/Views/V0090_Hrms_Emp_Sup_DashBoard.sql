





CREATE VIEW [dbo].[V0090_Hrms_Emp_Sup_DashBoard]
AS
SELECT     HAID.Appr_Detail_Id, HAID.Appr_Int_Id, HAID.Emp_Id, HAID.Is_Emp_Submit, HAID.Is_Sup_submit, HAID.Is_team_submit, HAID.Is_Accept, 
                      HAID.Emp_Submit_Date, HAID.Sup_Submit_Date, HAID.team_submit_date, HAID.start_date, HAID.End_date, EM.Emp_Superior, EM.Cmp_ID, 
                      EM.Emp_Full_Name, EM.Emp_code, CAST(EM.Emp_code AS Varchar) + '-' + EM.Emp_Full_Name AS Emp_Name, 
                      dbo.T0090_Hrms_Appraisal_Initiation.For_Date
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HAID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON HAID.Emp_Id = EM.Emp_ID INNER JOIN
                      dbo.T0090_Hrms_Appraisal_Initiation WITH (NOLOCK) ON HAID.Appr_Int_Id = dbo.T0090_Hrms_Appraisal_Initiation.Appr_Int_Id




