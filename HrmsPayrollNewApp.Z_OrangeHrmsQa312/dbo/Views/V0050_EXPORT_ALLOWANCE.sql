


/****** Created By Shaikh Ramiz on 09/01/2015 ******/
CREATE VIEW [dbo].[V0050_EXPORT_ALLOWANCE]
AS
SELECT     CMP_ID, AD_NAME, AD_SORT_NAME, CASE WHEN ISNULL(AD_FLAG, 'I') = 'I' THEN 'Earnings' ELSE 'Deduction' END AS Earning_or_Deduction, AD_CALCULATE_ON, 
                      AD_LEVEL AS Sorting_Number, CASE WHEN isnull(Allowance_Type, 'A') = 'A' THEN 'Salary Head' ELSE 'Reimbursement' END AS Allowance_Type, 
                      CASE WHEN ISNULL(AD_PART_OF_CTC, 1) = 1 THEN 'Yes' ELSE 'No' END AS Is_Part_of_CTC, CASE WHEN Isnull(AD_ACTIVE, 1) 
                      = 1 THEN 'Active' ELSE 'Inactive' END AS Active_InActive, CASE WHEN ISNULL(AD_DEF_ID, 0) = 0 THEN '' WHEN ISNULL(AD_DEF_ID, 0) 
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
					  = 27 THEN 'Interest Subsidy' 
					  ELSE 'NEW DEF ID' END AS AD_DEF_ID, 					  
					  CASE WHEN ISNULL(Is_Optional, 1) = 1 THEN 'Yes' ELSE 'No' END AS Is_Optional, 
                      Hide_In_Reports
FROM         dbo.T0050_AD_MASTER WITH (NOLOCK)


