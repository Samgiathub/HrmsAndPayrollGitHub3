

-- =============================================
-- Author:		<Jaina>
-- Create date: <16-03-2018>
-- Description:	<Allowance Master Detail>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Allowance_Deduction_Export]
	@Cmp_ID numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    select AD_NAME As [Allowance Name],AD_SORT_NAME as [Short Name],CASE WHEN isnull(Allowance_Type,'A') = 'A' THEN 'Salary Head' ELSE 'Reimbursement' END as [Allowance Type],
    AD_CALCULATE_ON + Isnull(' + ' +  STUFF((SELECT '+ ' + A1.AD_NAME 
          FROM T0050_AD_MASTER A1 WITH (NOLOCK) inner JOIN T0060_EFFECT_AD_MASTER EA WITH (NOLOCK) ON EA.AD_ID = a1.AD_ID
          WHERE A.Ad_ID = EA.EFFECT_AD_ID
         ORDER BY A1.AD_NAME
         FOR XML PATH('')), 1, 1,''), '') [CalCulate On],
    AD_LEVEL As [Sorting No],
    CASE WHEN ISNULL(AD_DEF_ID, 0) = 0 THEN '' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 1 THEN 'TDS' WHEN ISNULL(AD_DEF_ID, 0) = 2 THEN 'PF' WHEN ISNULL(AD_DEF_ID, 0) = 3 THEN 'ESIC' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 4 THEN 'VPF' WHEN ISNULL(AD_DEF_ID, 0) = 5 THEN 'Company PF' WHEN ISNULL(AD_DEF_ID, 0) = 6 THEN 'Company ESIC' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 7 THEN 'Arear PF' WHEN ISNULL(AD_DEF_ID, 0) = 8 THEN 'LTA' WHEN ISNULL(AD_DEF_ID, 0) = 9 THEN 'Medical' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 10 THEN 'PF Admin Charges' WHEN ISNULL(AD_DEF_ID, 0) = 11 THEN 'DA' WHEN ISNULL(AD_DEF_ID, 0) = 12 THEN 'VDA' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 13 THEN 'Extra TDS' WHEN ISNULL(AD_DEF_ID, 0) = 14 THEN 'GPF (General Provident Fund)' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 15 THEN 'Company CPS (Contributory Pension Scheme)' WHEN ISNULL(AD_DEF_ID, 0) = 16 THEN 'EPS (Employee Pension Scheme)' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 17 THEN 'HRA' WHEN ISNULL(AD_DEF_ID, 0) = 18 THEN 'Conveyance' WHEN ISNULL(AD_DEF_ID, 0) = 19 THEN 'Bonus' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 20 THEN 'Production Bonus' WHEN ISNULL(AD_DEF_ID, 0) = 21 THEN 'Production Variable' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 22 THEN 'PT' WHEN ISNULL(AD_DEF_ID, 0) = 23 THEN 'Car Retention' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 24 THEN 'PLI (Performance Linked Incentive)' WHEN ISNULL(AD_DEF_ID, 0) = 25 THEN 'Gratuity' WHEN ISNULL(AD_DEF_ID, 0) 
                      = 26 THEN 'Group Insurance'  WHEN ISNULL(AD_DEF_ID, 0) 
					  = 27 THEN 'Interest Subsidy' WHEN ISNULL(AD_DEF_ID, 0) 
					  = 28 THEN 'Average Salary'
					  ELSE 'NEW DEF ID' END AS [Def Id],   
    isnull(AE.AD_Formula_Eligible,'') as [Eligible Formula] ,
	 isnull(AF.AD_Formula,'') As Formula,
    CASE WHEN ISNULL(AD_FLAG, 'I') = 'I' THEN 'Earnings' ELSE 'Deduction' END AS [Type],
	 CASE WHEN Isnull(AD_ACTIVE, 1) = 1 THEN 'Active' ELSE 'Inactive' END AS [Active/InActive],
	 case WHEN isnull(A.AD_NOT_EFFECT_SALARY,0) = 1 THEN 'Yes' ELSE 'No' END As [Not Effect On Salary],
	 case WHEN isnull(A.AD_EFFECT_ON_CTC,0) = 1 THEN 'Yes' ELSE 'No' END As [Effect On Gross],
	 case WHEN ISNULL(A.AD_NOT_EFFECT_ON_PT,0) = 1 THEN 'Yes' ELSE 'No' END as [Not Effect On Profession Tax],
	 case WHEN isnull(A.AD_EFFECT_ON_OT,0) = 1 THEN 'Yes' ELSE 'No' END As [Effect On Overtime],
	 case WHEN ISNULL(A.AD_NOT_EFFECT_ON_LWP,0) = 1 THEN 'Yes' ELSE 'No' END as [Not Effect On LWP],
	 case WHEN ISNULL(A.AD_NOT_EFFECT_SALARY,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect Net Salary],
	 case WHEN ISNULL(A.AD_PART_OF_CTC,0) = 1 THEN 'Yes' ELSE 'No' END as [Part Of CTC],
	 case WHEN ISNULL(A.AD_EFFECT_ON_TDS,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On TDS],
	 case WHEN ISNULL(A.FOR_FNF,0) = 1 THEN 'Yes' ELSE 'No' END as [For FNF],
	 case WHEN ISNULL(A.AD_EFFECT_ON_BONUS,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On Bonus],
	 case WHEN ISNULL(A.AD_EFFECT_ON_LEAVE,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On Leave Encashment],
	 case WHEN ISNULL(A.Add_in_sal_amt,0) = 1 THEN 'Yes' ELSE 'No' END as [Add In Salary Amount(Display)],
	 case WHEN ISNULL(A.AD_EFFECT_ON_SHORT_FALL,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On Short Fall],
	 case WHEN ISNULL(A.Ad_Effect_on_Nighthalt,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On Night Halt],
	 case WHEN ISNULL(A.Ad_Effect_on_Gatepass,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On GatePass],
	 case WHEN ISNULL(A.is_Rounding,0) = 1 THEN 'Yes' ELSE 'No' END as [Is Rounding],
	 case WHEN ISNULL(A.Show_In_Pay_Slip,0) = 1 THEN 'Yes' ELSE 'No' END as [Show In SalarySlip],
	 case WHEN ISNULL(A.Ad_Effect_On_Esic,0) = 1 THEN 'Yes' ELSE 'No' END as [Effect On ESIC],
	 case WHEN ISNULL(A.Is_Calculated_On_Imported_Value,0) = 1 THEN 'Yes' ELSE 'No' END as [Cal On ImportedValue],
	 case WHEN ISNULL(A.AD_EFFECT_ON_TDS,0) = 1 THEN 'Yes' ELSE 'No' END as [Auto Deduct TDS],
	 case WHEN ISNULL(A.Hide_In_Reports,0) = 1 THEN 'Yes' ELSE 'No' END as [Hide In Reports],
	 case WHEN ISNULL(A.Not_display_auto_credit_amount_IT,0) = 1 THEN 'Yes' ELSE 'No' END as [Hide auto credit amount IT],
	 
    --STUFF((SELECT ';' + CHAR(10) +  isnull(G.Grd_Name,'') + '(' + isnull(G2.AD_MODE,'AMT') + ' :' + cast(isnull(G2.AD_AMOUNT,0) AS varchar(10)) + ', Max Limit : ' + CAST(isnull(g2.AD_MAX_LIMIT,0) AS varchar(10)) + ',Tax Free Amount : ' + cast(isnull(g2.AD_NON_TAX_LIMIT,0) as varchar(10)) + ' )'   ----cast(isnull(G2.AD_PERCENTAGE,0) as varchar(10)),cast(isnull(G2.AD_AMOUNT,0) AS varchar(10)))
				--  FROM T0040_GRADE_MASTER G INNER JOIN T0120_GRADEWISE_ALLOWANCE G2 ON g2.Grd_ID = G.Grd_ID
				--  WHERE G2.Ad_ID = A.Ad_ID
				--  ORDER BY Grd_Name
				--  FOR XML PATH('')), 1, 1, '') Grade_Allocation,
	
     isnull(A.AD_RPT_DEF_ID,0)as [Report Def Id],
     case when isnull(A.AD_IT_DEF_ID,0) = 7 then 'HRA Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 8 then 'Education Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 9 then 'Conveyance Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 151 then 'LTA Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 11 then 'Medical Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 160 then 'Petrol Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 161 then 'Telephone Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 162 then 'B N P Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 163 then 'Meal Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 164 then 'Vehical Exem.'
		  when isnull(A.AD_IT_DEF_ID,0) = 164 then 'Uniform Exem.'
	ELSE '' END as [IT Def Id],
     isnull(AD_EFFECT_MONTH,'')as [Effective Month],
     case when isnull(A.Auto_Paid,0) = 1 THEN 'Yes' ELSE 'No' END As AutoPaid,isnull(AD_CAL_TYPE,'') As [Release On],
	 isnull(R.Non_Taxable_Limit,0) As [Tax Free Application Limit],
	 case WHEN ISNULL(A.Display_Balance,0) = 1 THEN 'Yes' ELSE 'No' END as [Display Balance],
	 isnull(R.Taxable_Limit,0) as [Taxable Application Limit],
	 case WHEN ISNULL(A.Attached_Mandatory,0) = 1 THEN 'Yes' ELSE 'No' END as [Attachment Mandatory],
	 isnull(A.Monthly_Limit,0) as [Monthly Limit],
	 case WHEN ISNULL(A.Negative_Balance,0) = 1 THEN 'Yes' ELSE 'No' END as [Allow Negative Balance],
	 isnull(A.Reim_Guideline,'') as [Reimbursement Guideline],
	 case WHEN ISNULL(A.Display_In_Salary,0) = 1 THEN 'Yes' ELSE 'No' END as [Display In Reimbursement Slip],
	 case WHEN ISNULL(A.DefineReimExpenseLimit,0) = 1 THEN 'Yes' ELSE 'No' END as [Add Reimbursement Sub Expense],
	 case WHEN ISNULL(R.Is_CF,0) = 1 THEN 'Yes' ELSE 'No' END as [Carry Forward NextYear],
	 case WHEN ISNULL(A.Is_Claim_Base,0) = 1 THEN 'Yes' ELSE 'No' END as [Claim Base Reimbursement],
	 isnull(Is_Optional,0)AS Optional ,isnull(AD_Code,'')as Code
	 
    from T0050_AD_MASTER A 	WITH (NOLOCK) left OUTER JOIN
		 t0040_ReimClaim_Setting R WITH (NOLOCK) ON A.AD_ID = R.AD_ID and a.CMP_ID = R.Cmp_ID left OUTER JOIN
		 T0040_AD_Formula_Setting AF WITH (NOLOCK) ON A.AD_ID = AF.AD_Id and AF.Cmp_Id = A.CMP_ID left OUTER JOIN
		 T0040_AD_Formula_Eligible_Setting AE WITH (NOLOCK) ON a.ad_id = AE.ad_id and a.Cmp_id = AE.Cmp_id
    where A.CMP_ID = @Cmp_ID --and A.AD_ID IN (952,742,671)
    
    
		-- SELECT   
		--a.AD_ID, 
		--STUFF((SELECT '; ' + A1.AD_NAME 
		--		  FROM T0050_AD_MASTER A1 inner JOIN T0060_EFFECT_AD_MASTER EA ON EA.EFFECT_AD_ID = a1.AD_ID
		--		  WHERE A.Ad_ID = EA.AD_ID
		--		  ORDER BY A1.AD_NAME
		--		  FOR XML PATH('')), 1, 1, '') Effect_In_Allowance
		          
		--FROM T0050_AD_MASTER A  	 
		--where A.cmp_id = 149 AND A.Ad_ID = 671
		--GROUP BY A.Ad_ID
		--ORDER BY 1

END

