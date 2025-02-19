
CREATE PROCEDURE [dbo].[P0040_Employee_Strength_Master]	
	@Cmp_Id numeric(18,0)
	,@Branch_Id numeric(18,0)
	,@Dept_Id numeric(18,0)
	,@Desig_Id numeric(18,0)
	,@Effictive_Date Datetime
	,@Strength numeric(18,0)
	,@Tran_type varchar(1)
	,@Flag as varchar(2) = ''
	,@Cat_ID numeric(18,0) = 0	--Ankit 06112015
	,@Login_Id numeric(18,0) = 0	--Hardik 08/09/2020
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Tran_Id as numeric(18,0)
	IF @Tran_type = 'I' 
		BEGIN
			
			Select @Tran_Id = Isnull(max(Tran_Id),0) + 1  From dbo.T0040_Employee_Strength_Master WITH (NOLOCK)
			INSERT INTO T0040_Employee_Strength_Master (Tran_Id,Cmp_Id,Branch_Id,Dept_Id,Desig_Id,Effective_Date,Strength,Flag,Cat_ID, Login_Id,System_Datetime)
			VALUES (@Tran_Id,@Cmp_Id,@Branch_Id,@Dept_Id,@Desig_Id,@Effictive_Date,@Strength,@Flag,@Cat_ID,@Login_Id,GETDATE())
			
		END
END


