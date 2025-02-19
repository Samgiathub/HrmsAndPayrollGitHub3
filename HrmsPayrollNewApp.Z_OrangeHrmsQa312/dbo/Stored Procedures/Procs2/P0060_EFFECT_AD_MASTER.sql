



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_EFFECT_AD_MASTER]
	@AD_TRAN_ID numeric output
   ,@AD_ID numeric
   ,@CMP_ID numeric
   ,@EFFECT_AD_ID numeric
   ,@tran_type varchar(1)
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--If @tran_type ='i' 
			begin
				If exists (Select AD_TRAN_ID  from T0060_EFFECT_AD_MASTER WITH (NOLOCK) Where AD_ID = @AD_ID and EFFECT_AD_ID = @EFFECT_AD_ID and Cmp_ID =@cmp_ID) 
					begin
						set @AD_TRAN_ID = 0
						Return
					end
						
					select @AD_TRAN_ID = isnull(max(AD_TRAN_ID),0) + 1  From T0060_EFFECT_AD_MASTER WITH (NOLOCK)
					
					INSERT INTO T0060_EFFECT_AD_MASTER
					                      (AD_TRAN_ID, AD_ID, CMP_ID, EFFECT_AD_ID)
					VALUES (@AD_TRAN_ID,@AD_ID,@CMP_ID,@EFFECT_AD_ID)
					set @AD_TRAN_ID = 1
				end 
/*	Else If @tran_type ='u' 
				begin
					Update T0060_EFFECT_AD_MASTER
					set EFFECT_AD_ID = @EFFECT_AD_ID
					where AD_TRAN_ID = @AD_TRAN_ID
					
				end
				
	Else If @tran_type ='d'
			Begin
					DELETE FROM T0060_EFFECT_AD_MASTER WHERE AD_TRAN_ID = @AD_TRAN_ID  
			End
		
*/	
	
	RETURN




