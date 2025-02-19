

-- =============================================
-- Author:		<Sumit>
-- ALTER date: <28112015,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EXPENSE_TYPE_MAX_LIMIT_PETROL] 
	     @Tran_ID			NUMERIC(18,0) OUTPUT,
	     @Cmp_ID			NUMERIC(18,0) ,
	     @Expense_Type_ID	NUMERIC(18,0) ,
		 @Grd_Id			numeric(18,0),
		 @Rate_KM			NUMERIC(18,2),
		 @Flag_GrdDesig tinyint=0,		 
		 @EffectDate datetime,		
		 @Max_KM numeric(8,2),
		 @DesigID numeric(18,0),
		 @Tran_Type			VARCHAR(1)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

BEGIN
	If Upper(@Tran_Type) = 'I'
			BEGIN
				--IF EXISTS (SELECT TRAN_ID  FROM T0050_EXPENSE_TYPE_MAX_KM WHERE CMP_ID = @Cmp_ID AND Expense_Type_ID = @Expense_Type_ID and Max_KM=@Max_KM and (GRD_ID = @Grd_Id or Desig_ID=@DesigID))  
				--	BEGIN
				--	--print 'sdp'
				--		set @Tran_ID = 0
				--		Return 
				--	END
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_KM WITH (NOLOCK)

				INSERT INTO T0050_EXPENSE_TYPE_MAX_KM
				           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Flag_Grd_Desig,Max_KM,Desig_ID,Effective_Date,KM_Rate)
				VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Flag_GrdDesig,@Max_KM,@DesigID,@EffectDate,@Rate_KM)	
				
  			end 
	Else If  Upper(@tran_type) ='U' 
			BEGIN			
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_KM	WITH (NOLOCK)							
				
				INSERT INTO T0050_EXPENSE_TYPE_MAX_KM
				           (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Flag_Grd_Desig,Max_KM,Desig_ID,Effective_Date,KM_Rate)
				VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Flag_GrdDesig,@Max_KM,@DesigID,@EffectDate,@Rate_KM)	
				
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
				DELETE FROM T0050_EXPENSE_TYPE_MAX_KM WHERE  TRAN_ID = @Tran_ID AND CMP_ID = @CMP_ID
			END
			
	RETURN
END


