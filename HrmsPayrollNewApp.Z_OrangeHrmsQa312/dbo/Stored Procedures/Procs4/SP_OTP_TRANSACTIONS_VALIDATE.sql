
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_OTP_TRANSACTIONS_VALIDATE]
	-- Add the parameters for the stored procedure here
	@Emp_ID	numeric(18, 0),
	@Cmp_ID	numeric(18, 0),
	@Otp_Code	varchar(5),
	@Msg Varchar(250) ='' OUTPUT,
	@User_Type Varchar(8)= 'Ess',
	@Email Varchar(250)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @Curr_Date as datetime
	declare @Created_Date as datetime

	set @Curr_Date = getdate()


	IF @User_Type <>'Admin'
	Begin
		if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Emp_Id  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Emp_Id,0) = isnull(@Emp_Id,0) Group by Emp_Id) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Emp_ID =Qry.Emp_ID And VT.CreatedDate = Qry.CreatedDate  where VT.Otp_TypeID = 1 and VT.Otp_Code <> @Otp_Code And VT.IsVerified=0)
		begin	
				Set @Msg = 'Verification code is wrong.'
		end
		else if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Emp_ID  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Emp_Id,0) = isnull(@Emp_Id,0) Group by Emp_id) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Emp_ID =Qry.Emp_ID And VT.CreatedDate = Qry.CreatedDate where VT.Otp_TypeID = 1 and VT.Otp_Code = @Otp_Code And VT.IsVerified=1)
		begin	
				Set @Msg = 'Verification code is already used.'
		end
		else if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Emp_ID  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Emp_Id,0) = isnull(@Emp_Id,0) Group by Emp_id) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Emp_ID =Qry.Emp_ID And VT.CreatedDate = Qry.CreatedDate where VT.Otp_TypeID = 1 and datediff(mi, VT.CreatedDate, GETDATE()) >= 15)--Ronakb080224 otp expiry
		begin	
				Set @Msg = 'Verification code expired.'
		end
		else
		begin
				print 'OK'
				Set @Msg = ''
		end
	End
	Else
	Begin
		if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Email  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Email,'') = isnull(@Email,'') Group by Email) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Email =Qry.Email And VT.CreatedDate = Qry.CreatedDate  where VT.Otp_TypeID = 1 and VT.Otp_Code <> @Otp_Code And VT.IsVerified=0)
		begin	
				Set @Msg = 'Verification code is wrong.'
		end
		else if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Email  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Email,'') = isnull(@Email,'') Group by Email) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Email =Qry.Email And VT.CreatedDate = Qry.CreatedDate where VT.Otp_TypeID = 1 and VT.Otp_Code = @Otp_Code And VT.IsVerified=1)
		begin	
				Set @Msg = 'Verification code is already used.'
		end
		else if exists(Select 1 from (Select max(T.CreatedDate) as CreatedDate, Email  from T0011_OTP_TRANSACTIONS T WITH (NOLOCK) Where isnull(Email,'') = isnull(@Email,'') Group by Email) Qry Inner join T0011_OTP_TRANSACTIONS VT WITH (NOLOCK) on VT.Email =Qry.Email And VT.CreatedDate = Qry.CreatedDate where VT.Otp_TypeID = 1 and datediff(mi, VT.CreatedDate, GETDATE()) >= 15) --Ronakb080224 otp expiry
		begin	
				Set @Msg = 'Verification code expired.'
		end
		else
		begin
				print 'OK'
				Set @Msg = ''
		end

	End

	Select @Msg
END
