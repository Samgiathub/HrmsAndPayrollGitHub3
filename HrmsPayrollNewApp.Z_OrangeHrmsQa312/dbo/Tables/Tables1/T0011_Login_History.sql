CREATE TABLE [dbo].[T0011_Login_History] (
    [Row_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]     NUMERIC (18)  NOT NULL,
    [Login_ID]   NUMERIC (18)  NOT NULL,
    [Login_Date] DATETIME      NOT NULL,
    [Ip_Address] VARCHAR (50)  NOT NULL,
    [InterNetIP] VARCHAR (100) NULL,
    [MacAddress] VARCHAR (100) NULL,
    CONSTRAINT [PK_T0011_Login_History] PRIMARY KEY CLUSTERED ([Row_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0011_Login_History_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0011_Login_History_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0011_Login_History_Login_ID]
    ON [dbo].[T0011_Login_History]([Login_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0011_Login_History_11_453576654__K3_K4D]
    ON [dbo].[T0011_Login_History]([Login_ID] ASC, [Login_Date] DESC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_453576654_3_2]
    ON [dbo].[T0011_Login_History]([Login_ID], [Cmp_ID]);

