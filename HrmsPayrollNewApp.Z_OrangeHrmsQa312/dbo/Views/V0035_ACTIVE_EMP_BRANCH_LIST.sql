


CREATE VIEW [dbo].[V0035_ACTIVE_EMP_BRANCH_LIST]
AS
SELECT     ROW_NUMBER() OVER (ORDER BY b.Branch_NAME, b.Branch_ID) AS ROW_NO, b.Branch_ID AS ID, b.Branch_Name AS NAME, b.Cmp_ID
FROM         t0030_branch_master b WITH (NOLOCK) INNER JOIN
                      V0080_EMPLOYEE_MASTER e WITH (NOLOCK)  ON b.Branch_ID = e.Branch_ID
WHERE     e.Emp_Left = 'N' AND b.IsActive = 1
GROUP BY b.Branch_ID, b.Branch_Name, b.Cmp_ID

