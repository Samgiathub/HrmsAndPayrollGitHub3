

-- =============================================
-- Author     :	Alpesh
-- ALTER date: 15-Jun-2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_Gross_Amount]
	
 @Cmp_ID		numeric
,@Emp_Id		numeric
,@Increment_Id	numeric
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	

	Declare @Basic_Salary	numeric(18,2)
    Declare @Gross_Salary	numeric(18,2)
    Declare @Inc_Allowance_Amt	numeric(18,2)
   
	Select @Basic_Salary=Basic_Salary from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id and Increment_ID=@Increment_Id
	
	Select @Inc_Allowance_Amt=SUM(E_AD_AMOUNT) from T0100_EMP_EARN_DEDUCTION e WITH (NOLOCK) inner join T0050_AD_MASTER ad WITH (NOLOCK) on ad.AD_ID=e.AD_ID 
	where e.Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id and Increment_ID=@Increment_Id and e.E_AD_FLAG='I' and isnull(ad.AD_NOT_EFFECT_SALARY,0)=0 --and AD_CALCULATE_ON <> 'Import'
	
	Set @Gross_Salary = isnull(@Basic_Salary,0) + ISNULL(@Inc_Allowance_Amt,0)

	Update T0095_INCREMENT Set
		Gross_Salary = @Gross_Salary
	where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id and Increment_ID=@Increment_Id
		
	/*
	CREATE TABLE #EMP_ESIC
	(
		Emp_ID		Numeric,
		AD_ID		Numeric,			
		AD_Amount	Numeric(18,4),
		ED_Amount	Numeric(18,4),
		ED_Percent	Numeric(18,4),
		Last_Amount	Numeric(18,4),
		AD_Flag		Char(1),
		Flag_ID		INT,		--10 For ESIC, 20 For Special, 30 For Gross			
		ROW_ID		INT	Identity(1,1),
		LABEL		VARCHAR(128)
	)	
	
	IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION E 
					INNER JOIN T0050_AD_MASTER AD ON E.AD_ID=AD.AD_ID 
			  WHERE AD_CALCULATE_ON='Arrears CTC' AND Increment_ID=@Increment_Id)	--For Special ON Gross
		AND EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION E
						INNER JOIN T0050_AD_MASTER AD ON E.AD_ID=AD.AD_ID 
					WHERE AD_DEF_ID=3 AND Increment_ID=@Increment_Id)	--FOR ESIC
		
		EXEC P_CALCULATE_ESIC @Increment_ID=@Increment_Id
	
	IF EXISTS(SELECT 1 FROM #EMP_ESIC WHERE LABEL='GROSS' AND AD_AMOUNT > 0)	
		BEGIN
			
			UPDATE	I
			SET		Gross_Salary = AD_AMOUNT
			FROM	T0095_INCREMENT I
					INNER JOIN #EMP_ESIC CTC ON I.EMP_ID=CTC.EMP_ID 
			where	Cmp_ID=@Cmp_ID and I.Emp_ID=@Emp_Id and Increment_ID=@Increment_Id
					AND CTC.FLAG_ID=70 --GROSS
					
			
			UPDATE	ED
			SET		E_AD_AMOUNT = AD_AMOUNT
			FROM	T0100_EMP_EARN_DEDUCTION ED
					INNER JOIN #EMP_ESIC CTC ON ED.EMP_ID=CTC.EMP_ID AND ED.AD_ID=CTC.AD_ID
			where	Cmp_ID=@Cmp_ID and ED.Emp_ID=@Emp_Id and Increment_ID=@Increment_Id 
					AND CTC.FLAG_ID=90 --ESIC
			
			UPDATE	ED
			SET		E_AD_AMOUNT = AD_AMOUNT
			FROM	T0100_EMP_EARN_DEDUCTION ED
					INNER JOIN #EMP_ESIC CTC ON ED.EMP_ID=CTC.EMP_ID AND ED.AD_ID=CTC.AD_ID
			where	Cmp_ID=@Cmp_ID and ED.Emp_ID=@Emp_Id and Increment_ID=@Increment_Id
					AND CTC.FLAG_ID=50 --SPECIAL
		END
	ELSE
		BEGIN
			Update T0095_INCREMENT Set
				Gross_Salary = @Gross_Salary
			where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id and Increment_ID=@Increment_Id
		END
	*/
END


