CREATE Procedure [dbo].[P9999_DEVICE_INOUT_DETAIL_CHECK_EXIXTS] 
(
	@Cmp_ID     numeric(18,0),
	@Enroll_No  numeric(22,0),
	@IO_Datetime datetime,
	@Ip_Address varchar(50),
	@In_Out_flag char(10)
)
As
Begin
	select * from T9999_DEVICE_INOUT_DETAIL where 
	Cmp_ID = @Cmp_ID and 
	Enroll_No = @Enroll_No and 
	IO_DateTime = @IO_Datetime;
End