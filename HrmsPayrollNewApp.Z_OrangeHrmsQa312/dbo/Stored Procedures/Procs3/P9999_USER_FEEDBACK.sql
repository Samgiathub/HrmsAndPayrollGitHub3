



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_USER_FEEDBACK] 
		@USER_ID	numeric(18, 0)	output
		,@USER_NAME	varchar(100)	
		,@CMP_NAME	varchar(100)	
		,@CMP_ADDRESS	varchar(100)	
		,@LOCATION	varchar(50)	
		,@CMP_TEL_NO	varchar(100)	
		,@MOB_NO	varchar(50)	
		,@EMAIL_ID	varchar(100)	
		,@COMMENTS	varchar(1000)	
		,@IP_ADDRESS	varchar(50)
		,@tran_type as varchar(1)	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
				
		begin
				--if exists(select USER_ID from T9999_USER_FEEDBACK where upper(EMAIL_ID) = upper(@EMAIL_ID) )
					--begin
					--set @USER_ID = 0
					--Return 
					--end

				select @USER_ID = Isnull(max(USER_ID),0) + 1 	From T9999_USER_FEEDBACK WITH (NOLOCK)
				
				INSERT INTO T9999_USER_FEEDBACK
				                      (
										USER_ID	
										,USER_NAME	
										,CMP_NAME	
										,CMP_ADDRESS	
										,LOCATION	
										,CMP_TEL_NO
										,MOB_NO	
										,EMAIL_ID	
										,COMMENTS	
										,POST_DATE	
										,IP_ADDRESS
									  )
				VALUES     (
								 @USER_ID	
								,@USER_NAME	
								,@CMP_NAME	
								,@CMP_ADDRESS	
								,@LOCATION	
								,@CMP_TEL_NO
								,@MOB_NO	
								,@EMAIL_ID	
								,@COMMENTS	
								,getdate()
								,@IP_ADDRESS
							)	
		end
			Else if @Tran_Type = 'D'
		begin
				Delete From T9999_USER_FEEDBACK Where USER_ID = @USER_ID
		end
	RETURN




