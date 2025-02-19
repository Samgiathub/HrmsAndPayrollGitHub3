



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0011_OTP_TRANSACTIONS] 
	-- Add the parameters for the stored procedure here
	@Otp_ID	numeric(18, 0) OUTPUT,
	@Otp_TypeID	numeric(18, 0),
	@Emp_ID	numeric(18, 0),
	@Cmp_ID	numeric(18, 0),
	@Otp_Code	varchar(5),
	@Email	varchar(150),
	@MobileNo	varchar(20),
	@IsVerified	bit	,
	@Tran_Type char
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Expired_Mins as int
	Set @Expired_Mins= 15      --Ronakb070224
    -- Insert statements for procedure here
	IF @Tran_Type ='I' 
		BEGIN
		
					SELECT @Otp_ID = isnull(max(Otp_ID),0) + 1 FROM T0011_OTP_TRANSACTIONS WITH (NOLOCK)
						
					INSERT INTO T0011_OTP_TRANSACTIONS(Otp_ID,Otp_TypeID,Emp_ID,Cmp_ID,Otp_Code,Email,MobileNo,CreatedDate,ExpiredDate,IsVerified)
					VALUES(@Otp_ID,@Otp_TypeID,@Emp_ID,@Cmp_ID,@Otp_Code,@Email,@MobileNo,GETDATE(),DATEADD(minute, @Expired_Mins, GETDATE()),@IsVerified) 

       END  
	ELSE IF @Tran_Type ='U' 
		BEGIN		      		
					
				UPDATE T0011_OTP_TRANSACTIONS 
				SET    IsVerified=@IsVerified          
				WHERE Otp_Code = @Otp_Code and CONVERT(VARCHAR(12),CreatedDate,103)  =CONVERT(VARCHAR(12),GETDATE(),103)   

				Set @Otp_ID= 1 
				  
		END	
	ELSE IF @Tran_Type ='D'
		BEGIN
			DELETE  FROM T0011_OTP_TRANSACTIONS WHERE Otp_ID=@Otp_ID or (Otp_Code = @Otp_Code and CONVERT(VARCHAR(12),CreatedDate,103)  =CONVERT(VARCHAR(12),GETDATE(),103)   )
		END
			

	RETURN
END

