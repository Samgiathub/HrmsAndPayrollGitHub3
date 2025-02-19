



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RECORD_FOR_REMINDER]
 @CMP_ID	   NUMERIC(18,0)
,@Current_Date DATETIME
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Leave_Count AS NUMERIC(18,0)
DECLARE @Loan_Count  AS NUMERIC(18,0)
DECLARE @Claim_Count AS NUMERIC(18,0)
SET @Leave_Count=0
SET @Loan_Count=0
SET @Claim_Count=0
DECLARE @Record_Count TABLE 
(
	Cmp_ID		NUMERIC(18,0),
	Leave_Count NUMERIC(18,0),
	Loan_Count  NUMERIC(18,0),
	Claim_Count NUMERIC(18,0)
)

		SELECT @Leave_Count=COUNT(Leave_Application_ID) FROM T0100_LEAVE_APPLICATION WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Application_Status='P'
		
		INSERT INTO @Record_Count(Cmp_ID,Leave_Count,Loan_Count,Claim_Count) VALUES
								 (@Cmp_ID,@Leave_Count,0,0)
								 
		SELECT @Loan_Count=COUNT(Loan_App_ID) FROM T0100_LOAN_APPLICATION WITH (NOLOCK) WHERE  Cmp_ID=@Cmp_ID AND Loan_Status='N'
		UPDATE 	@Record_Count SET Loan_Count=@Loan_Count  WHERE Cmp_ID=@Cmp_ID
		
		SELECT @Claim_Count=COUNT(Claim_App_ID) FROM T0100_CLAIM_APPLICATION WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Claim_App_Status='P'
		UPDATE 	@Record_Count SET Claim_Count=@Claim_Count  WHERE Cmp_ID=@Cmp_ID
		
		SELECT * FROM @Record_Count 						 
		
RETURN




