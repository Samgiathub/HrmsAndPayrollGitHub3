
-- =============================================
-- Author: satish viramgami
-- Create date: 04/9/2020
-- Description:	Add mobile remark while sales and stock in vivo WB 
----- Table T0040_MOBILE_STOCK_SALES_REMARK
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_SaleStockRemark]
		@Mobile_Remark_ID  numeric(18,0),
		@Cmp_ID NUMERIC(18,0),
		@Remark_Name VARCHAR(250),
		@Login_ID NUMERIC(18,0),
		@Type CHAR(1),
		@Result varchar(100) OUT
AS
BEGIN

	
	IF @Type='I'
	BEGIN
			INSERT INTO T0040_MOBILE_STOCK_SALES_REMARK
			(Cmp_ID,Remark_Name,System_Date,Login_ID)
			VALUES
			(@Cmp_ID,@Remark_Name,GETDATE(),@Login_ID)
			
			SET @Result='Record Insert Sucessfully#True'
	END
	ELSE IF @Type='U'
	BEGIN
			UPDATE T0040_MOBILE_STOCK_SALES_REMARK
			SET Remark_Name=@Remark_Name,
				Login_ID=@Login_ID
			WHERE Mobile_Remark_ID = @Mobile_Remark_ID
			
			SET @Result='Record Updated Sucessfully#True'
	END
	ELSE IF @Type='S'
	BEGIN
			SELECT Mobile_Remark_ID,Remark_Name
			FROM T0040_MOBILE_STOCK_SALES_REMARK WITH(NOLOCK)
			WHERE Cmp_ID=@Cmp_ID
	END
		
END
