




--==========================================================
--ALTER BY : NILAY 29-DECEMBER-2010
--MANUALLY CHANGE DOCUMENT OF LOAN APPROVAL TABLE
---NIIT PURPOSE TO UPDATE LOAN_NUMBER
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

--==========================================================
CREATE PROCEDURE [dbo].[EmployeeTable]
	@Cmp_ID		NUMERIC(18,0),
	@Emp_code	NUMERIC(18,0),
	@BankAc		VARCHAR(50)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE table #Emp
	 (
	     Emp_code NUMERIC(18,0),
	     BankAc   VARCHAR(50) 
	 )
	
	DECLARE @Emp_ID AS NUMERIC(18,0)
	INSERT INTO #Emp (Emp_code,BankAc) VALUES (@Emp_code,@BankAc)
    SELECT @Emp_ID =Emp_ID FROM T0080_emp_master WITH (NOLOCK) WHERE emp_code=@Emp_code
	UPDATE T0120_Loan_Approval SET Loan_Number =@BankAc WHERE Emp_ID=@Emp_ID AND Loan_ID =6 OR Loan_ID =7
	
RETURN




