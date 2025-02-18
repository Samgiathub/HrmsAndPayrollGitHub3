﻿





CREATE VIEW [dbo].[V0050_LEAVE_DETAILS_EMPLOYEE]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0040_GRADE_MASTER.Grd_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0080_EMP_MASTER.Cmp_ID
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID AND 
                      dbo.T0080_EMP_MASTER.Cmp_ID = dbo.T0040_GRADE_MASTER.Cmp_ID INNER JOIN
                      dbo.T0050_LEAVE_DETAIL WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0050_LEAVE_DETAIL.Grd_ID AND 
                      dbo.T0040_GRADE_MASTER.Cmp_ID = dbo.T0050_LEAVE_DETAIL.Cmp_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0050_LEAVE_DETAIL.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID AND 
                      dbo.T0050_LEAVE_DETAIL.Cmp_ID = dbo.T0040_LEAVE_MASTER.Cmp_ID




