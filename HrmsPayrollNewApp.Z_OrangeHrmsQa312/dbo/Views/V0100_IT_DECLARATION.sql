﻿





CREATE VIEW [dbo].[V0100_IT_DECLARATION]
AS
SELECT     dbo.T0070_IT_MASTER.IT_Name, dbo.T0100_IT_DECLARATION.IT_TRAN_ID, 
                      dbo.T0100_IT_DECLARATION.IT_ID, dbo.T0100_IT_DECLARATION.FOR_DATE, dbo.T0100_IT_DECLARATION.AMOUNT, 
                      dbo.T0100_IT_DECLARATION.DOC_NAME, dbo.T0080_EMP_MASTER.Emp_First_Name, ISNULL(dbo.T0100_IT_DECLARATION.REPEAT_YEARLY, 0) 
                      AS Repeat_Yearly,dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Cmp_ID, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Full_Name
FROM         dbo.T0070_IT_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0100_IT_DECLARATION WITH (NOLOCK)  ON dbo.T0070_IT_MASTER.IT_ID = dbo.T0100_IT_DECLARATION.IT_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_IT_DECLARATION.EMP_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID




