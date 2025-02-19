





CREATE VIEW [dbo].[V0200_Monthly_Salary_Email]
AS
SELECT     dbo.T0200_MONTHLY_SALARY.Sal_Tran_ID, dbo.T0200_MONTHLY_SALARY.Sal_Receipt_No, dbo.T0200_MONTHLY_SALARY.Emp_ID, 
                      dbo.T0200_MONTHLY_SALARY.Cmp_ID, dbo.T0200_MONTHLY_SALARY.Increment_ID, dbo.T0200_MONTHLY_SALARY.Month_St_Date, 
                      dbo.T0200_MONTHLY_SALARY.Month_End_Date, dbo.T0200_MONTHLY_SALARY.Sal_Generate_Date, dbo.T0200_MONTHLY_SALARY.Sal_Cal_Days, 
                      dbo.T0200_MONTHLY_SALARY.Present_Days, dbo.T0200_MONTHLY_SALARY.Absent_Days, dbo.T0200_MONTHLY_SALARY.Holiday_Days, 
                      dbo.T0200_MONTHLY_SALARY.Weekoff_Days, dbo.T0200_MONTHLY_SALARY.Cancel_Holiday, dbo.T0200_MONTHLY_SALARY.Cancel_Weekoff, 
                      dbo.T0200_MONTHLY_SALARY.Working_Days, dbo.T0200_MONTHLY_SALARY.Outof_Days, dbo.T0200_MONTHLY_SALARY.Total_Leave_Days, 
                      dbo.T0200_MONTHLY_SALARY.Paid_Leave_Days, dbo.T0200_MONTHLY_SALARY.Actual_Working_Hours, 
                      dbo.T0200_MONTHLY_SALARY.Working_Hours, dbo.T0200_MONTHLY_SALARY.Outof_Hours, dbo.T0200_MONTHLY_SALARY.OT_Hours, 
                      dbo.T0200_MONTHLY_SALARY.Total_Hours, dbo.T0200_MONTHLY_SALARY.Shift_Day_Sec, dbo.T0200_MONTHLY_SALARY.Shift_Day_Hour, 
                      dbo.T0200_MONTHLY_SALARY.Basic_Salary, dbo.T0200_MONTHLY_SALARY.Day_Salary, dbo.T0200_MONTHLY_SALARY.Hour_Salary, 
                      dbo.T0200_MONTHLY_SALARY.Salary_Amount, dbo.T0200_MONTHLY_SALARY.Allow_Amount, dbo.T0200_MONTHLY_SALARY.OT_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Other_Allow_Amount, dbo.T0200_MONTHLY_SALARY.Gross_Salary, dbo.T0200_MONTHLY_SALARY.Dedu_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Loan_Amount, dbo.T0200_MONTHLY_SALARY.Loan_Intrest_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Advance_Amount, dbo.T0200_MONTHLY_SALARY.Other_Dedu_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Total_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Due_Loan_Amount, dbo.T0200_MONTHLY_SALARY.Net_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Actually_Gross_Salary, dbo.T0200_MONTHLY_SALARY.PT_Amount, 
                      dbo.T0200_MONTHLY_SALARY.PT_Calculated_Amount, dbo.T0200_MONTHLY_SALARY.Total_Claim_Amount, 
                      dbo.T0200_MONTHLY_SALARY.M_OT_Hours, dbo.T0200_MONTHLY_SALARY.M_Adv_Amount, dbo.T0200_MONTHLY_SALARY.M_Loan_Amount, 
                      dbo.T0200_MONTHLY_SALARY.M_IT_Tax, dbo.T0200_MONTHLY_SALARY.LWF_Amount, dbo.T0200_MONTHLY_SALARY.Revenue_Amount, 
                      dbo.T0200_MONTHLY_SALARY.PT_F_T_Limit, dbo.T0080_EMP_MASTER.Date_Of_Birth, dbo.T0080_EMP_MASTER.Pan_No, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Other_Email, dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0080_EMP_MASTER.Dept_ID, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0080_EMP_MASTER.Desig_Id, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_BANK_MASTER.Bank_Name, dbo.T0080_EMP_MASTER.Bank_ID, 
                      dbo.T0080_EMP_MASTER.Type_ID, dbo.T0040_TYPE_MASTER.Type_Name, dbo.T0040_BANK_MASTER.Bank_Ac_No, 
                      dbo.T0080_EMP_MASTER.SSN_No, dbo.T0080_EMP_MASTER.SIN_No
FROM         dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0200_MONTHLY_SALARY.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID INNER JOIN
    dbo.T0040_BANK_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Bank_ID = dbo.T0040_BANK_MASTER.Bank_ID INNER JOIN
                      dbo.T0040_TYPE_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Type_ID = dbo.T0040_TYPE_MASTER.Type_ID




