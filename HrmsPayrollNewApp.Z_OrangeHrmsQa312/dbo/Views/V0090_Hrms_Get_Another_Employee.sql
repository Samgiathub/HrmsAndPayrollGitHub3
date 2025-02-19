





CREATE VIEW [dbo].[V0090_Hrms_Get_Another_Employee]
AS
SELECT     TOP 100 PERCENT dbo.T0095_INCREMENT.Emp_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0095_INCREMENT.Increment_ID, 
                      dbo.T0095_INCREMENT.Increment_Effective_Date
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
ORDER BY dbo.T0080_EMP_MASTER.Emp_ID




