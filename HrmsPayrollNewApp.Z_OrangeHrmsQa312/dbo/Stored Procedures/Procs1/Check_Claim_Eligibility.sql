CREATE PROCEDURE Check_Claim_Eligibility 
@EmpID numeric(18,2),
@CmpID numeric(18,2)

AS
BEGIN
Select COUNT(1) from T0100_CLAIM_APPLICATION where Claim_ID = 117 and Emp_ID = @EmpID and Cmp_ID = @CmpID and Claim_App_Status <> 'R'
END