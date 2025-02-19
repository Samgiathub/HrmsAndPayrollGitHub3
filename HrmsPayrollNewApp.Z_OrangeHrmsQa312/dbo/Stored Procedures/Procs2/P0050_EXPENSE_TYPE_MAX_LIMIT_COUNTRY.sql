


-- =============================================
-- Author:		<Sumit>
-- ALTER date: <25112015,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EXPENSE_TYPE_MAX_LIMIT_COUNTRY] 
	     @Tran_ID			NUMERIC(18,0) OUTPUT,
	     @Cmp_ID			NUMERIC(18,0) ,
	     @Expense_Type_ID	NUMERIC(18,0) ,
		 @Grd_Id			VARCHAR(50),
		 @Amount			NUMERIC(18,2),
		 @Flag_GrdDesig tinyint=0,
		 --@Flag_CityCat tinyint=0,
		 @EffectDate datetime,
		 @CountryCatID numeric(18,0),
		 @CountryCatAmnt numeric(8,2),
		 @DesigID numeric(18,0),
		 @Tran_Type			VARCHAR(1)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If Upper(@Tran_Type) = 'I'
			BEGIN
				--IF EXISTS (SELECT TRAN_ID  FROM T0050_EXPENSE_TYPE_MAX_LIMIT_COuntry WHERE CMP_ID = @Cmp_ID AND Expense_Type_ID = @Expense_Type_ID and Country_Cat_ID=@CountryCatID and Country_cat_Amount=@Amount and (GRD_ID = @Grd_Id or Desig_ID=@DesigID))  
				--	BEGIN
				--	--print 'sdp'
				--		set @Tran_ID = 0
				--		Return 
				--	END
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT_country WITH (NOLOCK)

				INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT_country
				           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Flag_Grd_Desig,Country_Cat_ID,Country_Cat_Amount,Desig_ID,Effective_Date)
				VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Flag_GrdDesig,@CountryCatID,@CountryCatAmnt,@DesigID,@EffectDate)	
				
  			end 
	Else If  Upper(@tran_type) ='U' 
			BEGIN
				
				
				--DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID = @CMP_ID				
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT_country WITH (NOLOCK)
				
				
				--UPDATE    T0050_EXPENSE_TYPE_MAX_LIMIT
				--SET       Amount = @Amount,
				--City_Cat_Amount=@CityCatAmnt,
				--Flag_Grd_Desig=@Flag_GrdDesig,
				--City_Cat_Flag=@Flag_CityCat
				----Amount=@Amount
				--WHERE     Tran_ID = @Tran_ID And Expense_Type_ID = @Expense_Type_ID And Cmp_ID = @Cmp_ID and City_Cat_ID=@CityCatID
				--and Effective_Date=@EffectDate
				
				INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT_country
				           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Flag_Grd_Desig,Country_Cat_ID,Country_Cat_Amount,Desig_ID,Effective_Date)
				VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Flag_GrdDesig,@CountryCatID,@CountryCatAmnt,@DesigID,@EffectDate)	
				
				--IF EXISTS (SELECT TRAN_ID FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE Grd_ID = @Grd_Id AND EXPENSE_TYPE_ID <> @EXPENSE_TYPE_ID ) 
				--	BEGIN
				--		SET @Tran_ID = 0
				--		RETURN
				--	END
				
				--UPDATE    T0050_EXPENSE_TYPE_MAX_LIMIT
				--SET       Amount = @Amount
				--WHERE     Tran_ID = @Tran_ID And Expense_Type_ID = @Expense_Type_ID And Cmp_ID = @Cmp_ID
			END
	Else If  Upper(@tran_type) ='D'
			BEGIN	
				DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT_country WHERE  TRAN_ID = @Tran_ID AND CMP_ID = @CMP_ID
			END
			
	RETURN
END



