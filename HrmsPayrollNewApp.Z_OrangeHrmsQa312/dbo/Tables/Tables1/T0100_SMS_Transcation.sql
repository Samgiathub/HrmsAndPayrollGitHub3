CREATE TABLE [dbo].[T0100_SMS_Transcation] (
    [Tran_ID]       NUMERIC (18)   NOT NULL,
    [Cmp_ID]        NUMERIC (18)   NULL,
    [Emp_ID]        NUMERIC (18)   NULL,
    [For_Date]      DATETIME       NULL,
    [Module_Name]   VARCHAR (200)  NULL,
    [SMS_Text]      VARCHAR (1000) NULL,
    [Send_Flag]     TINYINT        NOT NULL,
    [SMS_Send_Date] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

