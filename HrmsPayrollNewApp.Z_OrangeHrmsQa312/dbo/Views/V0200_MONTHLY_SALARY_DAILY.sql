





CREATE VIEW [dbo].[V0200_MONTHLY_SALARY_DAILY]
AS
SELECT     MS.Sal_Tran_ID, MS.Sal_Receipt_No, MS.Emp_ID, MS.Cmp_ID, MS.Increment_ID, MS.Month_St_Date, MS.Month_End_Date, MS.Sal_Generate_Date, 
                      MS.Sal_Cal_Days, MS.Present_Days, MS.Absent_Days, MS.Holiday_Days, MS.Weekoff_Days, MS.Cancel_Holiday, MS.Cancel_Weekoff, 
                      MS.Working_Days, MS.Outof_Days, MS.Total_Leave_Days, MS.Paid_Leave_Days, MS.Actual_Working_Hours, MS.Working_Hours, MS.Outof_Hours, 
                      MS.OT_Hours, MS.Total_Hours, MS.Shift_Day_Sec, MS.Shift_Day_Hour, MS.Day_Salary, MS.Hour_Salary, MS.Salary_Amount AS basic_salary, 
                      MS.Allow_Amount, MS.OT_Amount, MS.Other_Allow_Amount, MS.Gross_Salary, MS.Dedu_Amount, MS.Loan_Amount, MS.Loan_Intrest_Amount, 
                      MS.Advance_Amount, MS.Other_Dedu_Amount, MS.Total_Dedu_Amount, MS.Due_Loan_Amount, MS.Net_Amount, MS.Actually_Gross_Salary, 
                      MS.PT_Amount, MS.PT_Calculated_Amount, MS.Total_Claim_Amount, MS.M_OT_Hours, MS.M_Adv_Amount, MS.M_Loan_Amount, MS.M_IT_Tax, 
                      MS.LWF_Amount, MS.Revenue_Amount, MS.PT_F_T_Limit, e.Dept_ID, e.Grd_ID, i.Branch_ID, e.Emp_Full_Name, BM.Branch_Name, e.Other_Email, 
                      ISNULL(MS.Is_FNF, 0) AS IS_FNF, e.IS_Emp_FNF, e.Emp_First_Name, e.Emp_code AS Emp_Code1, e.Alpha_Emp_Code AS Emp_Code
FROM         dbo.T0200_MONTHLY_SALARY_DAILY AS MS WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON MS.Emp_ID = e.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON MS.Increment_ID = i.Increment_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM  WITH (NOLOCK) ON i.Branch_ID = BM.Branch_ID




