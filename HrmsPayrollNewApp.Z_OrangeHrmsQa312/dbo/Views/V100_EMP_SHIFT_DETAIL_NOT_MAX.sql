





CREATE VIEW [dbo].[V100_EMP_SHIFT_DETAIL_NOT_MAX]
AS
SELECT     TOP 100 PERCENT Emp_ID, Shift_ID, For_Date, Cmp_ID, Shift_Tran_ID
FROM         dbo.T0100_EMP_SHIFT_DETAIL AS emp  WITH (NOLOCK) 
WHERE     (For_Date NOT IN
                          (SELECT     For_Date
                            FROM          dbo.V100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
                            WHERE      (Cmp_ID = 1) AND (Emp_ID = emp.Emp_ID)))
ORDER BY Emp_ID, For_Date




