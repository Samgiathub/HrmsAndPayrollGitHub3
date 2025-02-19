



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_BONUS_DETAIL]
			@Bonus_Tran_ID	numeric(18, 0) output
			,@Bonus_ID	numeric(18, 0)
			,@Cmp_ID	numeric(18, 0)
			,@Bonus_Calculated_Amount	numeric(18, 0)
			,@Bonus_Amount	numeric(18, 0)
			,@tran_type as char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type = 'I'
			begin
					If Exists(select Bonus_Tran_ID From T0190_BONUS_DETAIL WITH (NOLOCK) Where @Bonus_Tran_ID = Bonus_Tran_ID  AND CMP_ID=@CMP_ID )
						begin
							set @Bonus_Tran_ID = 0
							return 
					end
					select @Bonus_Tran_ID = Isnull(max(Bonus_Tran_ID),0) + 1 From T0190_BONUS_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0190_BONUS_DETAIL
				                      (
											Bonus_Tran_ID
											,Bonus_ID
											,Cmp_ID
											,Bonus_Calculated_Amount
											,Bonus_Amount

				                      )
								VALUES     
								(
											@Bonus_Tran_ID
											,@Bonus_ID
											,@Cmp_ID
											,@Bonus_Calculated_Amount
											,@Bonus_Amount

								)	
						
			END
			else if @tran_type ='U' 
				begin
								
						UPDATE  T0190_BONUS_DETAIL

						SET        
									Bonus_ID = @Bonus_ID 
									,Bonus_Calculated_Amount = @Bonus_Calculated_Amount
									,Bonus_Amount = @Bonus_Amount
				         where Bonus_Tran_ID = @Bonus_Tran_ID and CMP_ID = @CMP_ID
				end
	
	RETURN




