-- =============================================
-- Author:		satish viramgami
-- Create date:  03-09-2020
-- Description:	add and update mobile sals stock response of the vivo wb client
-- table T0130_EMP_MOBILE_STOCK_SALES
-- =============================================
CREATE PROCEDURE [dbo].[P0060_MobileSalesStock_Response]
		@Stock_Tran_ID numeric(18,0) OUTPUT,
		@Cmp_ID numeric(18,0),
		@Mobile_Cat_ID numeric(18,0),
		@Emp_ID	numeric(18,0),
		@Store_ID numeric(18,0),
		@Mobile_Cat_Sale numeric(18,0),
		@Mobile_Cat_Stock numeric(18,0),
		@Mobile_Remark_ID numeric(18,0),
		@Login_ID numeric(18,0),
		@Tran_Type char(1),
		@For_Date datetime
AS 
BEGIN
	
	DECLARE @ParentID AS numeric(18,0) 
			
	SELECT @ParentID=ParentCategory_ID
	FROM  T0040_MOBILE_CATEGORY WITH(NOLOCK) 
	WHERE Mobile_Cat_ID = @Mobile_Cat_ID
	
	IF @Tran_Type='I'
	BEGIN
		IF EXISTS(SELECT 1 FROM  T0130_EMP_MOBILE_STOCK_SALES WITH(NOLOCK) WHERE CMP_ID = @Cmp_ID AND CAST(For_Date as date) = CAST(@For_Date as date)  AND Emp_Id = @Emp_ID AND Mobile_Cat_ID=@Mobile_Cat_ID)
		BEGIN
			RETURN 0
		END
		ELSE
		BEGIN
			
			SELECT @Stock_Tran_ID = ISNULL(MAX(Stock_Tran_ID ),0) + 1 FROM T0130_EMP_MOBILE_STOCK_SALES
			
			INSERT INTO T0130_EMP_MOBILE_STOCK_SALES
			(Cmp_ID,Mobile_Cat_ID,Emp_ID,Store_ID,
			 For_Date,Mobile_Cat_Sale,Mobile_Cat_Stock,
			 Mobile_Remark_ID,System_Date,Login_ID,ParentID)
			VALUES
			(@Cmp_ID,@Mobile_Cat_ID,@Emp_ID,@Store_ID,
			 @For_Date,@Mobile_Cat_Sale,@Mobile_Cat_Stock,
			 @Mobile_Remark_ID,GETDATE(),@Login_ID,@ParentID)
			
		END
	END
	ELSE IF @Tran_Type='U'
	BEGIN
		
		IF EXISTS(SELECT 1 FROM  T0130_EMP_MOBILE_STOCK_SALES WITH(NOLOCK) WHERE Stock_Tran_ID=@Stock_Tran_ID)
		BEGIN
			
			UPDATE T0130_EMP_MOBILE_STOCK_SALES
			SET Mobile_Cat_Sale = @Mobile_Cat_Sale,
				Mobile_Cat_Stock = @Mobile_Cat_Stock,
				Mobile_Remark_ID=  @Mobile_Remark_ID,
				System_Date= GETDATE(),
				Login_ID= @Login_ID,
				ParentID= @ParentID,
				For_Date = @For_Date
			WHERE Stock_Tran_ID=@Stock_Tran_ID	
		END
			
	END

END



