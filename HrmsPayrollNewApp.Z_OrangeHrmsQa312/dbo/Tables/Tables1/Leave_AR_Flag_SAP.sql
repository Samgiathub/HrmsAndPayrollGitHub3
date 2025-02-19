CREATE TABLE [dbo].[Leave_AR_Flag_SAP] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [Leave_App_Id] NUMERIC (18) NULL,
    [Flag]         CHAR (10)    NULL,
    [CreatedDate]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

