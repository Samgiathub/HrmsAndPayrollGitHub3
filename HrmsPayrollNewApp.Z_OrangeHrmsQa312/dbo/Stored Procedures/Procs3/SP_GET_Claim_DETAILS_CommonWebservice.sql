

 ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_Claim_DETAILS_CommonWebservice]
	@Emp_Code varchar(50),
	@ForDate datetime,
	@Allowance_Code varchar(50),
	@Allowance_Amount numeric(18,0),
	@Comment varchar(255)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Cmp_ID numeric(18,0)
DECLARE @Month numeric(18,0)
DECLARE @Year numeric(18,0)

SET @Month = MONTH(@ForDate)
SET @Year = YEAR(@ForDate)
SET @Cmp_ID = (SELECT Cmp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Emp_Code)

 
--SELECT @Cmp_ID,@Emp_Code,@Month,@Year,@Allowance_Code,@Allowance_Amount,@Comment
IF @Cmp_ID IS NULL 
	BEGIN 
		SELECT 'Please Enter Valid Employee Code'
		RETURN 
	END
ELSE IF NOT EXISTS (SELECT AD_ID  FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_SORT_NAME =@Allowance_Code AND CMP_ID = @Cmp_ID )
	BEGIN 
		SELECT 'Please Enter Valid Allowance Code'
		RETURN
	END 
ELSE
	BEGIN
		EXEC P0190_Monthly_AD_Detail_Import @Cmp_ID,@Emp_Code,@Month,@Year,@Allowance_Code,@Allowance_Amount,@Comment,0,'I',0
	END 
RETURN 


