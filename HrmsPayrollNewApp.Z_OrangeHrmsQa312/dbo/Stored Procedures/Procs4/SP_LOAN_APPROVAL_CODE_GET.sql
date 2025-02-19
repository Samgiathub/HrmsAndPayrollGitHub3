




-- FOR LOAN RETURN
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LOAN_APPROVAL_CODE_GET]
	@CMP_ID		NUMERIC ,
	@BRANCH_ID	NUMERIC ,
	@FOR_DATE	DATETIME
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF @BRANCH_ID = 0
		SET	@BRANCH_ID = NULL
		
		
		SELECT LA.* FROM T0120_LOAN_APPROVAL LA WITH (NOLOCK) LEFT OUTER JOIN T0210_MONTHLY_LOAN_PAYMENT  MLP WITH (NOLOCK) ON
		 LA.LOAN_APR_ID = MLP.LOAN_APR_ID INNER JOIN 
		 ( select I.Emp_Id,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @FOR_DATE
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )I_Q ON --Changed by Hardik 09/09/2014 for Same Date Increment
				LA.EMP_ID = I_Q.EMP_ID 
		WHERE LA.CMP_ID =@CMP_ID and 
			 Branch_ID = isnull(@Branch_ID ,Branch_ID) and 
			 Loan_Apr_Pending_Amount > 0 
		
	
	
	RETURN




