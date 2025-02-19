



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_DEVICE_INOUT_DETAIL_INSERT_EDIL]
	@ENROLL_NO		NUMERIC,
	@IO_DateTime	Datetime,
	@IP_Address		varchar(50),
	@In_Out_Flag    Char(10),
	@Cmp_Id         Numeric(18,0)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @IO_Tran_ID_Device As Numeric 	
	Declare @Enroll_No_Cur As Numeric
	Declare @IO_DateTime_Cur As DateTime
	Declare @IP_Address_Cur As Varchar
	Declare @In_Out_Flag_Cur As Char
	Declare @IO_Tran_ID numeric(18,0)    
	Declare @Emp_Id As Numeric(18,0)
	Declare @For_Date Datetime
	Declare @In_Time Datetime 
	Declare @Out_Time Datetime     
	Set @For_Date = Cast(@IO_DATETIME as varchar(11))    
	
	
	if not exists(Select Enroll_No from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK) Where Enroll_No=@Enroll_No and IO_DateTime =@IO_DateTime And In_Out_Flag=@In_Out_Flag)
		Begin	
			Select @IO_Tran_ID_Device= isnull(Max(IO_Tran_ID),0) + 1  from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)		
			
			INSERT INTO T9999_DEVICE_INOUT_DETAIL
					   (IO_Tran_ID, Cmp_ID, Enroll_No, IO_DateTime, IP_Address,In_Out_Flag)
			VALUES     (@IO_Tran_ID_Device, @Cmp_ID, @Enroll_No, @IO_DateTime, @IP_Address,@In_Out_Flag)
		End
	RETURN




