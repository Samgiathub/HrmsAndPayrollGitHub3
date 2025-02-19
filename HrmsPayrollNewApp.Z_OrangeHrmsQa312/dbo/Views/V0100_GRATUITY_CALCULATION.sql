

CREATE VIEW [dbo].[V0100_GRATUITY_CALCULATION]
AS
SELECT     g.Emp_Id, e.Branch_ID, e.Emp_Full_Name, g.Paid_Date, g.Gr_Calc_Amount, g.Gr_Percentage, g.Gr_Days, bm.Branch_Name, bm.Branch_ID AS Branch,
                       g.Gr_Amount, g.Cmp_ID, i.Grd_ID, dgm.Desig_Name, dm.Dept_Name, i.Desig_Id, i.Dept_ID, e.Emp_code AS Emp_Code1, e.Emp_First_Name, e.Emp_Last_Name, 
                      e.Marital_Status, e.Gender, g.Gr_ID, e.Alpha_Emp_Code AS Emp_Code
                      ,i.Vertical_ID,i.SubVertical_ID ,g.Gr_Years --Added By Jaina 30-09-2015 -- Gr_Years -Added by Deepali -07012022
FROM         dbo.T0100_GRATUITY AS g WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON g.Emp_Id = e.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON e.Increment_ID = i.Increment_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON i.Branch_ID = bm.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS dgm WITH (NOLOCK)  ON i.Desig_Id = dgm.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS dm WITH (NOLOCK)  ON i.Dept_ID = dm.Dept_Id




