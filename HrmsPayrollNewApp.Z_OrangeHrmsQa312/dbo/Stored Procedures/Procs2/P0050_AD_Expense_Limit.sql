


-- =============================================
-- Author:		Ripal Patel
-- Create date: 04Nov2014
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_AD_Expense_Limit]
	 @AD_Exp_ID	as numeric(18,0) output ,
     @Cmp_ID as numeric(18,0),
     @AD_Exp_Master_ID as numeric(18,0),
     @Desig_ID as numeric(18,0),
     @Amount_Max_Limit as numeric(18,2),
     @Tran_type	CHAR(1),
	 @User_Id numeric(18,0) = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF @Tran_type = 'I'
	BEGIN
		
		select @AD_Exp_ID = isnull(max(AD_Exp_ID),0)+1 from T0050_AD_Expense_Limit WITH (NOLOCK)
		INSERT INTO T0050_AD_Expense_Limit
			   (AD_Exp_ID,Cmp_ID,AD_Exp_Master_ID,Desig_ID,Amount_Max_Limit,Created_Date,Created_By)
		 VALUES
			   (@AD_Exp_ID,@Cmp_ID,@AD_Exp_Master_ID,@Desig_ID,@Amount_Max_Limit,getdate(),@User_Id)
		
	End
	Else IF @Tran_type = 'U'
	BEGIN
	
		UPDATE T0050_AD_Expense_Limit
		   SET Desig_ID = @Desig_ID,
			   Amount_Max_Limit = @Amount_Max_Limit,
			   Modify_Date = getdate(),
			   Modify_By = @User_Id
		 WHERE AD_Exp_ID = @AD_Exp_ID and AD_Exp_Master_ID = @AD_Exp_Master_ID

	End
	Else IF @Tran_type = 'D'
	BEGIN
		
		if @AD_Exp_ID <> 0 
			Begin
				delete from T0050_AD_Expense_Limit 
					where AD_Exp_ID = @AD_Exp_ID
			End
		Else
			Begin
				delete from T0050_AD_Expense_Limit 
					where AD_Exp_Master_ID = @AD_Exp_Master_ID
			End
		
	End
	
END


