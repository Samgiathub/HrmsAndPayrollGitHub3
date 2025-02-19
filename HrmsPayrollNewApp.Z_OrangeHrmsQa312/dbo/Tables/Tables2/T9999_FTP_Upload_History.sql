CREATE TABLE [dbo].[T9999_FTP_Upload_History] (
    [FTP_History_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Login_ID]         NUMERIC (18)  NOT NULL,
    [FTP_Username]     VARCHAR (100) NULL,
    [FTP_Password]     VARCHAR (100) NULL,
    [Login_Date]       DATETIME      NOT NULL,
    [LocalIp_Address]  VARCHAR (50)  NULL,
    [GlobalIp_Address] VARCHAR (50)  NULL,
    [MacAddress]       VARCHAR (50)  NULL,
    [Ftp_FileName]     VARCHAR (200) NULL,
    [FileExtension]    NUMERIC (18)  NULL,
    [Mobile_Number]    VARCHAR (20)  NULL,
    [Remarks]          VARCHAR (500) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [CIX_FTP_Upload_LoginDate_Extension]
    ON [dbo].[T9999_FTP_Upload_History]([Cmp_ID] ASC, [Login_Date] DESC, [FileExtension] DESC);

