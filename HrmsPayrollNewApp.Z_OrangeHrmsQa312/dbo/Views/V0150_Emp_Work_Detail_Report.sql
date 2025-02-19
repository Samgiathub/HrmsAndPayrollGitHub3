





CREATE VIEW [dbo].[V0150_Emp_Work_Detail_Report]
AS
SELECT     dbo.T0010_COMPANY_MASTER.Cmp_Name, dbo.T0010_COMPANY_MASTER.Cmp_Address, dbo.T0010_COMPANY_MASTER.Cmp_Phone, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0150_EMP_WORK_DETAIL.Time_From, dbo.T0150_EMP_WORK_DETAIL.Time_To, 
                      dbo.T0150_EMP_WORK_DETAIL.Duration, dbo.T0150_EMP_WORK_DETAIL.Work_Date, dbo.T0150_EMP_WORK_DETAIL.Emp_ID, 
                      dbo.T0150_EMP_WORK_DETAIL.Cmp_Id, dbo.T0040_PROJECT_MASTER.Prj_name, dbo.T0040_WORK_MASTER.Work_name, 
                      dbo.T0150_EMP_WORK_DETAIL.Description, dbo.T0150_EMP_WORK_DETAIL.Prj_ID
FROM         dbo.T0150_EMP_WORK_DETAIL WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0150_EMP_WORK_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      dbo.T0150_EMP_WORK_DETAIL.Cmp_Id = dbo.T0080_EMP_MASTER.Cmp_ID INNER JOIN
                      dbo.T0040_PROJECT_MASTER WITH (NOLOCK)  ON dbo.T0150_EMP_WORK_DETAIL.Prj_ID = dbo.T0040_PROJECT_MASTER.Prj_ID AND 
                      dbo.T0150_EMP_WORK_DETAIL.Cmp_Id = dbo.T0040_PROJECT_MASTER.Cmp_ID INNER JOIN
                      dbo.T0040_WORK_MASTER WITH (NOLOCK)  ON dbo.T0150_EMP_WORK_DETAIL.Work_ID = dbo.T0040_WORK_MASTER.Work_ID AND 
                      dbo.T0150_EMP_WORK_DETAIL.Cmp_Id = dbo.T0040_WORK_MASTER.Cmp_ID INNER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0150_EMP_WORK_DETAIL.Cmp_Id = dbo.T0010_COMPANY_MASTER.Cmp_Id




