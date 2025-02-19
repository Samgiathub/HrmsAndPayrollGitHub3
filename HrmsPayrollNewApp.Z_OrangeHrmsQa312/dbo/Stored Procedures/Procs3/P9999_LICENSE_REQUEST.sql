



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_LICENSE_REQUEST]
		@LIC_REQ_ID	numeric(18, 0)	output
		,@CONTACT_PERSON	varchar(100)	
		,@CMP_NAME	varchar(100)	
		,@CMP_ADDRESS	varchar(250)	
		,@LOCATION	varchar(50)	
		,@TEL_NO	varchar(100)	
		,@MOB_NO	varchar(100)	
		,@EMAIL_ID	varchar(100)	
		,@NO_OF_EMP	numeric(10, 0)	
		,@OWN_SERVER	numeric(1, 0)	
		,@SUP_TYPE	numeric(2, 0)	
		,@MOD_REQUIRE	numeric(1, 0)
		,@MOD_COMMENTS	varchar(1000)
		,@IP_ADDRESS varchar(50)	
		,@tran_type as varchar(1)	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
				
		begin
				if exists(select LIC_REQ_ID from T9999_LICENSE_REQUEST WITH (NOLOCK) where upper(EMAIL_ID) = upper(@EMAIL_ID) )
					begin
					set @LIC_REQ_ID = 0
					Return 
					end

				select @LIC_REQ_ID = Isnull(max(LIC_REQ_ID),0) + 1 	From T9999_LICENSE_REQUEST WITH (NOLOCK)
				
				INSERT INTO T9999_LICENSE_REQUEST
				                      (
											 LIC_REQ_ID	
											,CONTACT_PERSON	
											,CMP_NAME	
											,CMP_ADDRESS
											,LOCATION
											,TEL_NO	
											,MOB_NO	
											,EMAIL_ID	
											,NO_OF_EMP	
											,REQ_DATE
											,OWN_SERVER	
											,SUP_TYPE	
											,MOD_REQUIRE
											,MOD_COMMENTS
											,IP_ADDRESS
										 )
				VALUES     (
											 @LIC_REQ_ID	
											,@CONTACT_PERSON	
											,@CMP_NAME	
											,@CMP_ADDRESS
											,@LOCATION
											,@TEL_NO	
											,@MOB_NO	
											,@EMAIL_ID	
											,@NO_OF_EMP	
											,getdate()
											,@OWN_SERVER	
											,@SUP_TYPE	
											,@MOD_REQUIRE
											,@MOD_COMMENTS
											,@IP_ADDRESS
							)	
		end
			Else if @Tran_Type = 'D'
		begin
				Delete From T9999_LICENSE_REQUEST Where LIC_REQ_ID = @LIC_REQ_ID
		end
	RETURN




