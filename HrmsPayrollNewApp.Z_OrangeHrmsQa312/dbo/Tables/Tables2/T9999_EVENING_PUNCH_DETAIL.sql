CREATE TABLE [dbo].[T9999_EVENING_PUNCH_DETAIL] (
    [IO_TRAN_ID]  INT           IDENTITY (1, 1) NOT NULL,
    [CMP_ID]      NUMERIC (18)  NULL,
    [Enroll_No]   NUMERIC (18)  NULL,
    [IO_DateTime] DATETIME      NULL,
    [IP_Address]  VARCHAR (100) NULL,
    [In_Out_flag] NUMERIC (18)  NULL,
    [Is_Verify]   INT           NULL,
    PRIMARY KEY CLUSTERED ([IO_TRAN_ID] ASC) WITH (FILLFACTOR = 95)
);

