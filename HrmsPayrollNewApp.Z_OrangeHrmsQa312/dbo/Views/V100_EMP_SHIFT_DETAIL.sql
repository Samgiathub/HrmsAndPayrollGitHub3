





CREATE VIEW [dbo].[V100_EMP_SHIFT_DETAIL]
AS
SELECT     TOP 100 PERCENT qry1.Emp_ID, qry1.Emp_Full_Name, qry1.For_Date, sm.Shift_ID, sm.Shift_Name, sm.Shift_St_Time, sm.Shift_End_Time, 
                      sm.Shift_Dur, qry1.Emp_Left, qry1.Grd_ID, qry1.Dept_ID, qry1.Cmp_ID
FROM         dbo.T0040_SHIFT_MASTER AS sm WITH (NOLOCK) INNER JOIN
                          (SELECT     em.Cmp_ID, em.Emp_ID, em.Emp_Full_Name, d.For_Date, CASE WHEN d .shift_id IS NULL 
                                                   THEN em.shift_id ELSE d .shift_id END AS shift_id, em.Emp_Left, em.Grd_ID, em.Dept_ID
                            FROM          dbo.T0100_EMP_SHIFT_DETAIL AS d WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(For_Date) AS max_for_date, Emp_ID
                                                         FROM          dbo.T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
                                                         GROUP BY Emp_ID) AS qry ON d.Emp_ID = qry.Emp_ID AND d.For_Date = qry.max_for_date RIGHT OUTER JOIN
                                                   dbo.T0080_EMP_MASTER AS em WITH (NOLOCK)  ON d.Emp_ID = em.Emp_ID) AS qry1 ON sm.Shift_ID = qry1.shift_id
ORDER BY qry1.Emp_ID




