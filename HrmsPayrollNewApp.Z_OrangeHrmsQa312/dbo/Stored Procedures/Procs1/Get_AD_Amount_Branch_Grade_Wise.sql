

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 05/09/2017
-- Description:	Get Allowance Amount Branch and Grade Wise
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_AD_Amount_Branch_Grade_Wise]
	@Branch_ID Numeric,
	@Grd_ID Numeric,
	@AD_ID Numeric,
	@Basic_Salary Numeric(18,2),
	@Gross_Salary Numeric(18,2),
	@CTC Numeric(18,2)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Select 
		  (CASE WHEN Isnull(AD_Amount,0) <> 0 and GB.AD_CALCULATE_ON = '0' THEN 
			   Isnull(AD_Amount,0)
			   WHEN Isnull(AD_Amount,0) <> 0 and GB.AD_CALCULATE_ON <> '0' THEN
					(CASE WHEN GB.AD_CALCULATE_ON = 'Basic Salary' THEN
						  (@Basic_Salary * Isnull(AD_Amount,0)/100)
						WHEN GB.AD_CALCULATE_ON = 'Gross Salary' THEN
						  (@Gross_Salary * Isnull(AD_Amount,0)/100)
				        WHEN GB.AD_CALCULATE_ON = 'CTC' THEN
						  (@CTC * Isnull(AD_Amount,0)/100)
					END)
		  END) as AD_Amount,
		  (CASE WHEN Isnull(AD_Amount,0) <> 0 and GB.AD_CALCULATE_ON <> '0' THEN
				Isnull(AD_Amount,0)
				Else 0
		  END) as AD_Percentage
	From T0100_AD_Grade_Branch_Wise GB WITH (NOLOCK)
	Inner Join(
				SELECT MAX(Effective_Date) as EffectiveDate,Branch_ID,Grd_ID,AD_ID 
				From T0100_AD_Grade_Branch_Wise WITH (NOLOCK)
				group by Branch_ID,Grd_ID,AD_ID
			  ) as Qry
	ON GB.Branch_ID = Qry.Branch_ID and GB.Grd_ID = Qry.Grd_ID and GB.AD_ID = Qry.AD_ID
	Where GB.Branch_ID = @Branch_ID and GB.Grd_ID = @Grd_ID and GB.AD_ID = @AD_ID
END

