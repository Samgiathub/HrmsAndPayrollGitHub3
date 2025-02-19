CREATE TABLE [dbo].[T9999_Last_Synchronization] (
    [Row_ID]      NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_Name]    VARCHAR (50) NULL,
    [Branch_Name] VARCHAR (50) NULL,
    [Ip_Address]  VARCHAR (50) NULL,
    [Last_Sync]   VARCHAR (50) NULL,
    CONSTRAINT [PK_T9999_Last_Synchronization] PRIMARY KEY CLUSTERED ([Row_ID] ASC) WITH (FILLFACTOR = 80)
);

