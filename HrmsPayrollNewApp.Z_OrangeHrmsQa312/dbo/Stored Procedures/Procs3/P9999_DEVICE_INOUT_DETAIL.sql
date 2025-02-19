
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_DEVICE_INOUT_DETAIL]
 @IO_tran_ID numeric(18,0)
,@Cmp_ID     numeric(18,0)
,@Enroll_No  numeric(22,0)
,@IO_Datetime datetime
,@Ip_Address varchar(50)  	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If @IO_Datetime > getdate() -- Added by rohit for Future Date Data restriction in table on 27102015
		Begin
			Return
		end

		select @IO_tran_ID = Isnull(max(IO_tran_ID),0) + 1  from T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
		
		select @IO_tran_ID
		insert into T9999_DEVICE_INOUT_DETAIL(IO_tran_ID,Cmp_ID,Enroll_No,IO_Datetime,Ip_Address)
		values(@IO_tran_ID,@Cmp_ID,@Enroll_No,@IO_Datetime,@Ip_Address)


	
RETURN




