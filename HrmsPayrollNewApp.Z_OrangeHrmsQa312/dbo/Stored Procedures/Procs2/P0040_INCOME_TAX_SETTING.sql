




-- Must be check before Using
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_INCOME_TAX_SETTING]
	 @Cmp_ID as Numeric(9) 
	,@Tran_ID as Numeric(18,0)
	,@For_Date as DateTime
	,@Row_Id as Numeric(18,0) output 
	,@From_Limit as Numeric(18,0)
	,@To_Limit as Numeric(18,0)
	,@Percentage as numeric(6,2)
	,@Flag as char(1)
	,@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin

				select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0040_INCOME_TAX_SETTING WITH (NOLOCK)
				
				INSERT INTO T0040_INCOME_TAX_SETTING
				        (
							  Cmp_ID 
							 ,Tran_ID 
							 ,For_Date 
							 ,Row_Id 
		                     ,From_Limit 
	                         ,To_Limit 
	                         ,Percentage 
							 ,Flag 
				        )
					VALUES     
						(
								 @Cmp_ID 
								,@Tran_ID 
								,@For_Date
								,@Row_Id 
								,@From_Limit 
								,@To_Limit 
								,@Percentage 
								,@Flag 
						)
		End
	Else if @Tran_Type = 'U'
		begin
				UPDATE    T0040_INCOME_TAX_SETTING
				SET              
								For_Date = @For_Date
								,From_Limit = @From_Limit
								,To_Limit = @To_Limit
								,Percentage = @Percentage
								,Flag = @Flag
				where Row_Id  = @Row_Id 
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0040_INCOME_TAX_SETTING Where  Row_Id  = @Row_Id 
		end
	
	RETURN
	



