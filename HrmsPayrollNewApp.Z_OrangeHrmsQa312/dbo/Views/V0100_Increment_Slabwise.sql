


CREATE VIEW [dbo].[V0100_Increment_Slabwise]
AS
SELECT DISTINCT 
                      isb.Gross_Salary, isb.Wages_Calculate_On, isb.Wages_Amount, isb.Eligible_Day, isb.Increment_Amount, isb.Total_Increment, em.Emp_Full_Name, isb.Cmp_ID, 
                      isb.Emp_ID, isb.Additional_Increment, isb.Working_Days, em.Alpha_Emp_Code, isb.Tran_ID, mm.Branch_ID, mm.Vertical_ID, mm.SubVertical_ID, mm.Dept_ID, 
                      mm.Type_ID, mm.Grd_ID, mm.Cat_ID, mm.Desig_Id, mm.Segment_ID, mm.subBranch_ID, em.Emp_First_Name, isb.From_date, isb.To_date
FROM         dbo.T0100_Increment_Slabwise AS isb WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS em WITH (NOLOCK)  ON isb.Emp_ID = em.Emp_ID AND isb.Cmp_ID = em.Cmp_ID LEFT OUTER JOIN
                          (SELECT     I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  INNER JOIN
                                                   dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON E.Emp_ID = I.Emp_ID
                            WHERE      (I.Increment_ID IN
                                                       (SELECT     MAX(Increment_ID) AS Expr1
                                                         FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                                                         GROUP BY Emp_ID))) AS mm ON em.Emp_ID = mm.Emp_ID AND em.Cmp_ID = mm.Cmp_ID

