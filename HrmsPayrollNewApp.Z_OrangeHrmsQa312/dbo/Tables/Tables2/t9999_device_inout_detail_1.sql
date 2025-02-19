CREATE TABLE [dbo].[t9999_device_inout_detail_1] (
    [IO_Tran_ID]  NUMERIC (18) NOT NULL,
    [Cmp_ID]      NUMERIC (18) NULL,
    [Enroll_No]   NUMERIC (18) NOT NULL,
    [IO_DateTime] DATETIME     NOT NULL,
    [IP_Address]  VARCHAR (50) NULL,
    [In_Out_flag] CHAR (10)    NULL
);

