
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_DEVICE_INOUT_DETAIL_INSERT_ODD_EVEN_DEVICE]  
	@ENROLL_NO		NUMERIC,
	@IO_DateTime	Datetime,
	@IP_Address		varchar(50),
	@Ver			Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @IO_Tran_ID numeric 
	Declare @Cmp_ID		numeric 
	
	If @IO_Datetime > getdate() -- Added by rohit For Future Date Data restriction on 27102015
		Begin
			Return
		end
	
	If cast(@IP_Address As Numeric) = 32      --------For LSG (Kerala) sql record came from Historty table located in access control server (31 for In flag & 32 for out flag)-------
		Set @Ver = 1
	Else
		Set @Ver = 0
	
	if not exists(select enroll_no from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK) Where Enroll_No=@Enroll_No and IO_DateTime =@IO_DateTime)
		Begin	
			Select @IO_Tran_ID= isnull(Max(IO_Tran_ID),0) + 1  from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
			select @Cmp_ID = Cmp_ID from dbo.T0080_emp_Master WITH (NOLOCK) where Enroll_no =@Enroll_No 
			
			if @cmp_id is null
			begin 
				return
			end
			
			INSERT INTO dbo.T9999_DEVICE_INOUT_DETAIL
				(IO_Tran_ID, Cmp_ID, Enroll_No, IO_DateTime, IP_Address,In_Out_flag)
			VALUES
			    (@IO_Tran_ID, @Cmp_ID, @Enroll_No, @IO_DateTime, @IP_Address,@Ver)
		End	
	RETURN
	



