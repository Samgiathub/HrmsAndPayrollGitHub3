CREATE TABLE [dbo].[Single_Device_Login] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Login_ID]     NUMERIC (18)  NULL,
    [Cmp_ID]       NUMERIC (18)  NULL,
    [IMEI_No]      VARCHAR (250) NULL,
    [Is_Logged_In] BIT           NULL,
    CONSTRAINT [PK_Single_Device_Login] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

