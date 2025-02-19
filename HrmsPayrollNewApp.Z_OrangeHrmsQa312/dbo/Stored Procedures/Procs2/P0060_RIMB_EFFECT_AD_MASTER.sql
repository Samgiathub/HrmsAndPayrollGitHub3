



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_RIMB_EFFECT_AD_MASTER]
 @RIMB_TRAN_ID numeric output
,@RIMB_ID numeric
,@CMP_ID NUMERIC
,@AD_ID numeric
,@tran_type varchar(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--	If @tran_type ='i' 
			begin
				If exists (Select RIMB_TRAN_ID  from T0060_RIMB_EFFECT_AD_MASTER WITH (NOLOCK) Where RIMB_ID = @RIMB_ID and AD_ID = @AD_ID and Cmp_ID =@cmp_ID) 
					begin
						set @RIMB_TRAN_ID = 0
						Return
					end
						
						
					select @RIMB_TRAN_ID = isnull(max(RIMB_TRAN_ID),0) + 1  From T0060_RIMB_EFFECT_AD_MASTER WITH (NOLOCK)
					
					INSERT INTO T0060_RIMB_EFFECT_AD_MASTER
					                      (RIMB_TRAN_ID, RIMB_ID, CMP_ID, AD_ID)
					VALUES (@RIMB_TRAN_ID, @RIMB_ID, @CMP_ID, @AD_ID)    
					
				end 
/*	Else If @tran_type ='u' 
				begin
					UPDATE    T0060_RIMB_EFFECT_AD_MASTER
					SET              AD_ID = @AD_ID
					where RIMB_TRAN_ID = @RIMB_TRAN_ID
					
				end
				
	Else If @tran_type ='d'
			Begin
					DELETE FROM T0060_RIMB_EFFECT_AD_MASTER WHERE RIMB_TRAN_ID = @RIMB_TRAN_ID
					  set @RIMB_TRAN_ID = 1
			End
		
	*/

	


