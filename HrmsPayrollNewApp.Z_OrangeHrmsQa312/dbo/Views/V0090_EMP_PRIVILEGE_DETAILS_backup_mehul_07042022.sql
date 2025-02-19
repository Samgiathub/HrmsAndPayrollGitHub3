




create VIEW [dbo].[V0090_EMP_PRIVILEGE_DETAILS_backup_mehul_07042022]
AS
SELECT     TOP (100) PERCENT ISNULL(CONVERT(NVARCHAR, PD.From_Date, 103), '-') AS FROM_DATE, ISNULL(CONVERT(NVARCHAR, PD.Privilege_Id), '-') AS PRIVILEGE_ID, 
                      LO.Cmp_ID, LO.Login_ID, EMP.Emp_Full_Name, EMP.Alpha_Emp_Code, ISNULL(PM.Privilege_Name, '-') AS PRIVILEGE_NAME, CASE CONVERT(NVARCHAR, 
                      PM.PRIVILEGE_TYPE) WHEN '0' THEN 'ADMIN USER' WHEN '1' THEN 'ESS USER' ELSE '-' END AS PRIVILEGE_TYPE, INC.Branch_ID, INC.Grd_ID, INC.Desig_Id, 
                      ISNULL(INC.Dept_ID, 0) AS Dept_ID, ISNULL(PD.Trans_Id, 0) AS Trans_Id, EMP.Emp_ID, INC.Vertical_ID, INC.SubVertical_ID,
					  INC.Cat_ID,INC.Segment_ID,INC.subBranch_ID,INC.Band_Id,INC.Type_ID,INC.SalDate_id,
					  PD.From_Date AS Effective_Date, 
                      EMP.Emp_First_Name
FROM         dbo.T0090_EMP_PRIVILEGE_DETAILS AS PD WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN AS LO  WITH (NOLOCK) ON LO.Login_ID = PD.Login_Id INNER JOIN
                      dbo.T0080_EMP_MASTER AS EMP  WITH (NOLOCK) ON EMP.Emp_ID = LO.Emp_ID LEFT OUTER JOIN
                      dbo.T0020_PRIVILEGE_MASTER AS PM  WITH (NOLOCK) ON PM.Privilege_ID = PD.Privilege_Id INNER JOIN
                      dbo.T0095_INCREMENT AS INC  WITH (NOLOCK) ON INC.Increment_ID = EMP.Increment_ID
WHERE     (EMP.Emp_Left = 'N')
ORDER BY EMP.Alpha_Emp_Code, Effective_Date

