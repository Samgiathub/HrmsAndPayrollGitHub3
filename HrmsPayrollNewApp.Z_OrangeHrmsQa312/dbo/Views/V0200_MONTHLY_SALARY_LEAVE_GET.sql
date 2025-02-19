





CREATE VIEW [dbo].[V0200_MONTHLY_SALARY_LEAVE_GET]
AS
SELECT     MS.L_Sal_Tran_ID, MS.L_Sal_Receipt_No, MS.Emp_ID, MS.Cmp_ID, MS.Increment_ID, MS.L_Month_St_Date, MS.L_Month_End_Date, 
                      MS.L_Sal_Generate_Date, MS.L_Sal_Cal_Days, MS.L_Working_Days, MS.L_Outof_Days, MS.L_Shift_Day_Sec, MS.L_Shift_Day_Hour, 
                      MS.L_Basic_Salary, MS.L_Day_Salary, MS.L_Hour_Salary, MS.L_Salary_Amount, MS.L_Allow_Amount, MS.L_Other_Allow_Amount, 
                      MS.L_Gross_Salary, MS.L_Dedu_Amount, MS.L_Loan_Amount, MS.L_Loan_Intrest_Amount, MS.L_Advance_Amount, MS.L_Other_Dedu_Amount, 
                      MS.L_Total_Dedu_Amount, MS.L_Due_Loan_Amount, MS.L_Net_Amount, MS.L_Actually_Gross_Salary, MS.L_PT_Amount, 
                      MS.L_PT_Calculated_Amount, MS.L_M_Adv_Amount, MS.L_M_Loan_Amount, MS.L_M_IT_Tax, MS.L_LWF_Amount, MS.L_Revenue_Amount, 
                      MS.L_PT_F_T_Limit, e.Dept_ID, e.Grd_ID, e.Emp_Full_Name, BM.Branch_Name, e.Other_Email, i.Branch_ID AS Expr1
FROM         dbo.T0200_MONTHLY_SALARY_LEAVE AS MS WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON MS.Emp_ID = e.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON MS.Increment_ID = i.Increment_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON i.Branch_ID = BM.Branch_ID




