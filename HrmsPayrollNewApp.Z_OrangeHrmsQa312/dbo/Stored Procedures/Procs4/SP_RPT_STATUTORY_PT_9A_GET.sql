


-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <31/07/2012>
-- Description:	<Developed For PT Challan Form-9A Report>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PT_9A_GET] 
	@Cmp_ID		NUMERIC
   ,@Branch_ID  NUMERIC
   ,@Month		NUMERIC
   ,@YEAR		NUMERIC     
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    IF @Branch_ID = 0  
		set @Branch_ID = NULL
		
		SELECT Distinct P.CMP_ID, ISNULL(P.BRANCH_ID,0) as BRANCH_ID, P.Bank_ID, B.Bank_Name, B.Bank_Branch_Name, C.Cmp_Name, C.Cmp_Address, P.Month, dbo.F_GET_MONTH_NAME(P.Month) + '/' + CAST(P.Year AS VARCHAR(20)) AS PERIOD_Payment, P.Year, SUM(P.Tax_Return_Amount) AS Tax_Return_Amount, SUM(P.Tax_Amount) AS Tax_Amount, SUM(P.Interest_Amount) AS Interest_Amount, SUM(P.Penalty_Amount) AS Penalty_Amount, SUM(P.Other_Amount) AS Other_Amount, SUM(P.Total_Amount) AS Total_Amount, dbo.F_Number_TO_Word(SUM(P.Total_Amount)) AS Total_IN_WORD
			FROM T0220_PT_CHALLAN P WITH (NOLOCK) INNER JOIN
				 T0010_COMPANY_MASTER C WITH (NOLOCK) ON P.Cmp_ID = C.Cmp_Id  INNER JOIN
				 T0040_BANK_MASTER B WITH (NOLOCK) ON P.Bank_ID = B.Bank_ID  
			WHERE P.Cmp_ID = @Cmp_ID AND P.Month = @Month AND P.Year = @YEAR AND P.BRANCH_ID = ISNULL(@Branch_ID,P.BRANCH_ID)	
			Group BY P.Cmp_ID,ISNULL(P.BRANCH_ID,0),P.Bank_ID, B.Bank_Name, B.Bank_Branch_Name, C.Cmp_Name, C.Cmp_Address ,P.Month, P.Year	
		
END
RETURN


