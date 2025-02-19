





/*i.Increment_ID  not in (select Increment_ID from T0080_emp_master )*/
CREATE VIEW [dbo].[V0095_INCREMENT_HRMS]
AS
SELECT     e.Emp_Full_Name, I.Increment_ID, I.Emp_ID, I.Cmp_ID, I.Branch_ID, I.Cat_ID, I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, I.Bank_ID, I.Curr_ID, 
                      I.Wages_Type, I.Salary_Basis_On, I.Basic_Salary, I.Gross_Salary, I.Increment_Type, I.Increment_Date, I.Increment_Effective_Date, I.Payment_Mode, 
                      I.Inc_Bank_AC_No, I.Emp_OT, I.Emp_OT_Min_Limit, I.Emp_OT_Max_Limit, I.Increment_Per, I.Increment_Amount, I.Pre_Basic_Salary, 
                      I.Pre_Gross_Salary, I.Increment_Comments, I.Emp_Late_mark, I.Emp_Full_PF, I.Emp_PT, I.Emp_Fix_Salary, e.Emp_First_Name, e.Emp_code, 
                      e.Emp_Left, b.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, I.Yearly_Bonus_Amount, I.Deputation_End_Date, e.Login_ID, I.Emp_Late_Limit, 
                      I.Is_Deputation_Reminder, I.Emp_Part_Time, I.Late_Dedu_Type, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = I.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON I.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON I.Emp_ID = e.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON I.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS b WITH (NOLOCK)  ON I.Branch_ID = b.Branch_ID




