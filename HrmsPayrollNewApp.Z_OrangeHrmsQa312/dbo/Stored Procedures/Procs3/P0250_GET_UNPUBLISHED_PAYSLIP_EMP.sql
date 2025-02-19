

-- =============================================
-- Author:		<Nimesh Parmar>
-- Create date: <11/05/2015>
-- Description:	<Unpublished salary slip employee detail in comma seperated format>
-- =============================================
CREATE PROCEDURE [dbo].[P0250_GET_UNPUBLISHED_PAYSLIP_EMP]
	@Cmp_ID Numeric(18,0),
	@Year Numeric(18,0),
	@Month Numeric(18,0),
	@R_Emp_ID Numeric(18,0) = 0
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

    IF (IsNull(@R_Emp_ID, 0) = 0)		
		WITH Temp(Emps) AS
		(
			SELECT	DISTINCT(CONVERT(NVARCHAR,SAL.Emp_ID)) + ','
			FROM	T0250_SALARY_PUBLISH_ESS SAL WITH (NOLOCK) INNER JOIN 
					(Select Emp_ID,MAX(Effect_Date) As Effective_Date, Cmp_ID, R_Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					Where Effect_Date <= GETDATE() 
					GROUP BY Emp_ID,Cmp_ID,R_Emp_ID) As ERD ON SAL.Emp_ID=ERD.Emp_ID AND SAL.Cmp_ID=ERD.Cmp_ID 
			WHERE	[MONTH]=@Month AND [YEAR]=@Year and SAL.Cmp_ID=@Cmp_ID AND SAL.Is_Publish=0 and SAL.Sal_Type='Salary' --Mukti(30062016)added Sal_Type
			FOR XML PATH ('')
		)
		SELECT SUBSTRING(Emps, 1, Len(Emps)-1) FROM Temp;
	ELSE		
		WITH Temp(Emps) AS
		(
			SELECT	DISTINCT(CONVERT(NVARCHAR,SAL.Emp_ID)) + ','
			FROM	T0250_SALARY_PUBLISH_ESS SAL WITH (NOLOCK) INNER JOIN 
					(Select Emp_ID,MAX(Effect_Date) As Effective_Date, Cmp_ID, R_Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					Where Effect_Date <= GETDATE() 
					GROUP BY Emp_ID,Cmp_ID,R_Emp_ID) As ERD ON SAL.Emp_ID=ERD.Emp_ID AND SAL.Cmp_ID=ERD.Cmp_ID 
			WHERE	[MONTH]=@Month AND [YEAR]=@Year and SAL.Cmp_ID=@Cmp_ID AND ERD.R_Emp_ID = @R_Emp_ID AND SAL.Is_Publish=0 and SAL.Sal_Type='Salary' --Mukti(30062016)added Sal_Type
			FOR XML PATH ('')
		)
		SELECT SUBSTRING(Emps, 1, Len(Emps)-1) FROM Temp;

END

