



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_REIMBURSEMENT]
	@RIMB_ID	numeric output
   ,@CMP_ID		numeric
   ,@RIMB_NAME	varchar(50)
   ,@RIMB_FLAG	char(1)
   ,@RIMB_LEVEL	 numeric
   ,@AD_ID		 numeric
   ,@tran_type	varchar(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @AD_ID= 0 
			set @AD_ID = null

		If @tran_type  = 'I' 
		Begin
				If Exists(select RIMB_ID From T0055_REIMBURSEMENT  WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									RIMB_NAME = @RIMB_NAME  )
					Begin
						set @RIMB_ID = 0
						Return 
					end
	
				select @RIMB_ID = Isnull(max(RIMB_ID),0) + 1 	From T0055_REIMBURSEMENT  WITH (NOLOCK)
				
				INSERT INTO T0055_REIMBURSEMENT
				                      (RIMB_ID, CMP_ID, RIMB_NAME, RIMB_FLAG, RIMB_LEVEL, AD_ID)
				VALUES (@RIMB_ID, @CMP_ID, @RIMB_NAME, @RIMB_FLAG, @RIMB_LEVEL, @AD_ID)
								
											
		End
	Else if @Tran_Type = 'U' 
		begin

				If Exists(select AD_ID From T0055_REIMBURSEMENT WITH (NOLOCK)  Where cmp_ID = @Cmp_ID and RIMB_ID <> @RIMB_ID and
									RIMB_NAME = @RIMB_NAME  )
					Begin
						set @RIMB_ID = 0
						Return 
					end
					
				Delete from T0060_RIMB_EFFECT_AD_MASTER  Where RIMB_ID = @RIMB_ID
				
				UPDATE    T0055_REIMBURSEMENT
				SET              RIMB_NAME = @RIMB_NAME, RIMB_FLAG = @RIMB_FLAG, RIMB_LEVEL = @RIMB_LEVEL, AD_ID = @AD_ID
				where cmp_ID = @Cmp_ID and RIMB_ID = @RIMB_ID
			 
		end
	Else if @Tran_Type = 'D' 
		begin
				delete from T0060_RIMB_EFFECT_AD_MASTER where RIMB_ID=@RIMB_ID
				delete from T0055_REIMBURSEMENT WHERE RIMB_ID = @RIMB_ID
				
		end


	
	RETURN




