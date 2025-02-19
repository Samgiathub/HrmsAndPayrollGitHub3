



CREATE VIEW [dbo].[V0075_EMP_EARN_DEDUCTION_APP_DETAILS]
AS
SELECT     TOP (100) PERCENT EED.Emp_Application_ID, EED.Emp_Tran_ID, AM.AD_NAME, EED.AD_TRAN_ID, EED.CMP_ID, EED.AD_ID, EED.INCREMENT_ID, CASE WHEN EED.Approved_Date IS NULL 
                      THEN EED.Approved_Date ELSE EED.Approved_Date END AS FOR_DATE, EED.E_AD_FLAG, EED.E_AD_MODE, CASE WHEN EED.E_AD_PERCENTAGE IS NULL 
                      THEN dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE, eed.cmp_id) ELSE dbo.F_Show_Decimal(EED.E_AD_PERCENTAGE, E.cmp_id) END AS E_AD_PERCENTAGE, 
                      CASE WHEN EED.E_Ad_Amount IS NULL THEN CASE WHEN Isnull(eed.Is_Calculate_Zero, 0) = 0 THEN dbo.F_Show_Decimal(eed.E_AD_Amount, eed.cmp_id) ELSE dbo.F_Show_Decimal(- 1, 
                      eed.cmp_id) END ELSE CASE WHEN Isnull(EED.Is_Calculate_Zero, 0) = 0 THEN dbo.F_Show_Decimal(EED.E_Ad_Amount, E.Cmp_ID) ELSE dbo.F_Show_Decimal(- 1, eed.cmp_id) 
                      END END AS E_Ad_Amount, EED.E_AD_MAX_LIMIT, AM.AD_LEVEL, AM.AD_NOT_EFFECT_SALARY, AM.AD_PART_OF_CTC, AM.AD_ACTIVE, AM.AD_NOT_EFFECT_ON_PT, AM.FOR_FNF, 
                      AM.NOT_EFFECT_ON_MONTHLY_CTC, AM.Is_Yearly, AM.Not_Effect_on_Basic_Calculation, AM.AD_CALCULATE_ON, AM.Effect_Net_Salary, AM.AD_EFFECT_MONTH, 
                      CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, AM.Add_in_sal_amt, AM.AD_DEF_ID, E.Alpha_Emp_Code, E.Emp_code, E.Emp_First_Name, E.Emp_Full_Name, 
                      E.Branch_ID, E.Grd_ID, AM.AD_EFFECT_ON_CTC, AM.Hide_In_Reports
FROM         dbo.T0075_EMP_EARN_DEDUCTION_APP AS EED WITH (NOLOCK) INNER JOIN
                      dbo.T0050_AD_MASTER AS AM WITH (NOLOCK)  ON EED.AD_ID = AM.AD_ID INNER JOIN
                      dbo.T0060_EMP_MASTER_APP AS E WITH (NOLOCK)  ON EED.Emp_Tran_ID = E.Emp_Tran_ID
ORDER BY EED.E_AD_FLAG DESC, AM.AD_LEVEL


