CREATE PROCEDURE P9999_DEVICE_INOUT_DETAIL_DATAINSERT
(
    @Cmp_ID     numeric(18,0),
    @Enroll_No  numeric(22,0),
    @IO_Datetime datetime,
    @Ip_Address varchar(50),
    @In_Out_flag char(10)
)
AS

    BEGIN
        -- Insert data if IU_Flag is 'I'
		Declare @IO_Tran_ID numeric 
	Select @IO_Tran_ID= isnull(Max(IO_Tran_ID),0) + 1  from dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)

        INSERT INTO T9999_DEVICE_INOUT_DETAIL (IO_Tran_ID, Cmp_ID, Enroll_No, IO_DateTime, IP_Address, In_Out_flag)
        VALUES (@IO_tran_ID, @Cmp_ID, @Enroll_No, @IO_Datetime, @Ip_Address, @In_Out_flag);
    END