---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_IT_Emp_Tax_Regime]
	@Tran_ID	NUMERIC(18,0) output
	,@Emp_ID	NUMERIC(18,0)
	,@Financial_Year VARCHAR(10)
    ,@Regime	VARCHAR(20)
    ,@User_ID	NUMERIC(18,0) = NULL
    ,@System_Date	DATETIME = null
    ,@Flag		CHAR(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @System_Date is null
		begin
			set @System_Date = getdate()
		end
	
	if @Regime = 'Old Regime'
		begin
			set @Regime = 'Tax Regime 1'
		end
	if @Regime = 'New Regime'
		begin
			set @Regime = 'Tax Regime 2'
		end
		
	IF @Flag = 'I'
		BEGIN
			
			IF @REGIME = '0' --Added by Jaina 17-08-2020
			BEGIN 
				DELETE FROM T0095_IT_EMP_TAX_REGIME WHERE	EMP_ID = @EMP_ID AND FINANCIAL_YEAR = @FINANCIAL_YEAR
				return
			END
			IF EXISTS (SELECT 1 FROM T0095_IT_Emp_Tax_Regime WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND Financial_Year = @Financial_Year)
				BEGIN
						UPDATE	T0095_IT_Emp_Tax_Regime
						SET		Regime = @Regime
						WHERE	Emp_ID = @Emp_ID AND Financial_Year = @Financial_Year
				END
			ELSE
				BEGIN
					SELECT @Tran_ID =  ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_IT_Emp_Tax_Regime WITH (NOLOCK)
					
				
						INSERT INTO T0095_IT_Emp_Tax_Regime (Tran_ID,Emp_ID,Financial_Year,Regime,[USER_ID],System_Date)
						VALUES(@Tran_ID,@Emp_ID,@Financial_Year,@Regime,@User_ID,@System_Date)
	
				END
		END
	ELSE IF @Flag = 'D'
		BEGIN
			DELETE FROM T0095_IT_Emp_Tax_Regime WHERE Tran_ID = @Tran_id AND Emp_ID = @Emp_ID
		END