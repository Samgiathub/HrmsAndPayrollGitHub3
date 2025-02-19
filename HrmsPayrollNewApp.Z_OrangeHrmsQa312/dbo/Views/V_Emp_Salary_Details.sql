



CREATE VIEW [dbo].[V_Emp_Salary_Details]
AS
SELECT     dbo.T0200_MONTHLY_SALARY.Sal_Tran_ID, dbo.T0200_MONTHLY_SALARY.Sal_Receipt_No, dbo.T0200_MONTHLY_SALARY.Emp_ID, 
                      dbo.T0200_MONTHLY_SALARY.Cmp_ID, dbo.T0200_MONTHLY_SALARY.Month_St_Date, dbo.T0200_MONTHLY_SALARY.Month_End_Date, 
                      dbo.T0200_MONTHLY_SALARY.Sal_Generate_Date, dbo.T0200_MONTHLY_SALARY.Sal_Cal_Days, dbo.T0200_MONTHLY_SALARY.Present_Days, 
                      dbo.T0200_MONTHLY_SALARY.Absent_Days, dbo.T0200_MONTHLY_SALARY.Holiday_Days, dbo.T0200_MONTHLY_SALARY.Weekoff_Days, 
                      dbo.T0200_MONTHLY_SALARY.Cancel_Holiday, dbo.T0200_MONTHLY_SALARY.Cancel_Weekoff, dbo.T0200_MONTHLY_SALARY.Working_Days, 
                      dbo.T0200_MONTHLY_SALARY.Outof_Days, dbo.T0200_MONTHLY_SALARY.Total_Leave_Days, dbo.T0200_MONTHLY_SALARY.Paid_Leave_Days, 
                      dbo.T0200_MONTHLY_SALARY.Actual_Working_Hours, dbo.T0200_MONTHLY_SALARY.Working_Hours, dbo.T0200_MONTHLY_SALARY.Outof_Hours, 
                      dbo.T0200_MONTHLY_SALARY.OT_Hours, dbo.T0200_MONTHLY_SALARY.Total_Hours, dbo.T0200_MONTHLY_SALARY.Shift_Day_Sec, 
                      dbo.T0200_MONTHLY_SALARY.Shift_Day_Hour, dbo.T0200_MONTHLY_SALARY.Basic_Salary, dbo.T0200_MONTHLY_SALARY.Day_Salary, 
                      dbo.T0200_MONTHLY_SALARY.Hour_Salary, dbo.T0200_MONTHLY_SALARY.Salary_Amount, dbo.T0200_MONTHLY_SALARY.Allow_Amount, 
                      dbo.T0200_MONTHLY_SALARY.OT_Amount, dbo.T0200_MONTHLY_SALARY.Other_Allow_Amount, dbo.T0200_MONTHLY_SALARY.Gross_Salary, 
                      dbo.T0200_MONTHLY_SALARY.Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Loan_Amount, dbo.T0200_MONTHLY_SALARY.Loan_Intrest_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Advance_Amount, dbo.T0200_MONTHLY_SALARY.Other_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Total_Dedu_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Due_Loan_Amount, dbo.T0200_MONTHLY_SALARY.Net_Amount, dbo.T0200_MONTHLY_SALARY.Actually_Gross_Salary, 
                      dbo.T0200_MONTHLY_SALARY.PT_Amount, dbo.T0200_MONTHLY_SALARY.PT_Calculated_Amount, dbo.T0200_MONTHLY_SALARY.Total_Claim_Amount, 
                      dbo.T0200_MONTHLY_SALARY.M_OT_Hours, dbo.T0200_MONTHLY_SALARY.M_Adv_Amount, dbo.T0200_MONTHLY_SALARY.M_Loan_Amount, 
                      dbo.T0200_MONTHLY_SALARY.M_IT_Tax, dbo.T0200_MONTHLY_SALARY.LWF_Amount, dbo.T0200_MONTHLY_SALARY.Revenue_Amount, 
                      dbo.T0200_MONTHLY_SALARY.PT_F_T_Limit, dbo.T0200_MONTHLY_SALARY.Settelement_Amount, dbo.T0200_MONTHLY_SALARY.Settelement_Comments, 
                      dbo.T0200_MONTHLY_SALARY.Leave_Salary_Amount, dbo.T0200_MONTHLY_SALARY.Leave_Salary_Comments, dbo.T0200_MONTHLY_SALARY.Late_Sec, 
                      dbo.T0200_MONTHLY_SALARY.Late_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Late_Extra_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Late_Days, 
                      dbo.T0200_MONTHLY_SALARY.Short_Fall_Days, dbo.T0200_MONTHLY_SALARY.Short_Fall_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Gratuity_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Is_FNF, dbo.T0200_MONTHLY_SALARY.Bonus_Amount, dbo.T0200_MONTHLY_SALARY.Incentive_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Trav_Earn_Amount, dbo.T0200_MONTHLY_SALARY.Cust_Res_Earn_Amount, dbo.T0200_MONTHLY_SALARY.Trav_Rec_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Mobile_Rec_Amount, dbo.T0200_MONTHLY_SALARY.Cust_Res_Rec_Amount, dbo.T0200_MONTHLY_SALARY.Uniform_Rec_Amount, 
                      dbo.T0200_MONTHLY_SALARY.I_Card_Rec_Amount, dbo.T0200_MONTHLY_SALARY.Excess_Salary_Rec_Amount, dbo.T0200_MONTHLY_SALARY.Salary_Status, 
                      dbo.T0200_MONTHLY_SALARY.Pre_Month_Net_Salary, dbo.T0200_MONTHLY_SALARY.IT_M_ED_Cess_Amount, 
                      dbo.T0200_MONTHLY_SALARY.IT_M_Surcharge_Amount, dbo.T0200_MONTHLY_SALARY.Early_Sec, dbo.T0200_MONTHLY_SALARY.Early_Dedu_Amount, 
dbo.T0200_MONTHLY_SALARY.Early_Extra_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Early_Days, dbo.T0200_MONTHLY_SALARY.Deficit_Sec, 
                      dbo.T0200_MONTHLY_SALARY.Deficit_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Deficit_Extra_Dedu_Amount, dbo.T0200_MONTHLY_SALARY.Deficit_Days, 
                      dbo.T0200_MONTHLY_SALARY.Total_Earning_Fraction, dbo.T0200_MONTHLY_SALARY.Late_Early_Penalty_days, dbo.T0200_MONTHLY_SALARY.M_WO_OT_Hours,
                       dbo.T0200_MONTHLY_SALARY.M_HO_OT_Hours, dbo.T0200_MONTHLY_SALARY.M_WO_OT_Amount, dbo.T0200_MONTHLY_SALARY.M_HO_OT_Amount, 
                      dbo.T0200_MONTHLY_SALARY.is_Monthly_Salary, dbo.T0200_MONTHLY_SALARY.Arear_Basic, dbo.T0200_MONTHLY_SALARY.Arear_Gross, 
                      dbo.T0200_MONTHLY_SALARY.Arear_Day, dbo.T0200_MONTHLY_SALARY.OD_Leave_Days, dbo.T0200_MONTHLY_SALARY.Extra_AB_Days, 
                      dbo.T0200_MONTHLY_SALARY.Extra_AB_Rate, dbo.T0200_MONTHLY_SALARY.Extra_AB_Amount, dbo.T0200_MONTHLY_SALARY.Access_Leave_Recovery, 
                      dbo.T0200_MONTHLY_SALARY.Access_Leave_Recovery_Day, dbo.T0200_MONTHLY_SALARY.Net_Salary_Round_Diff_Amount, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0095_INCREMENT.Cat_ID, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0095_INCREMENT.subBranch_ID, dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.Segment_ID, 
                      dbo.T0095_INCREMENT.SalDate_id, dbo.T0095_INCREMENT.Type_ID, dbo.T0095_INCREMENT.Increment_ID, 
                      dbo.T0200_MONTHLY_SALARY.Increment_ID AS Expr1
FROM         dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0200_MONTHLY_SALARY.Increment_ID = dbo.T0095_INCREMENT.Increment_ID


