CREATE TABLE [dbo].[SAP_Company] (
    [Cmp_ID]       INT           IDENTITY (1, 1) NOT NULL,
    [Company_Code] VARCHAR (50)  NULL,
    [Company_Name] VARCHAR (100) NULL,
    CONSTRAINT [PK_SAP_Company] PRIMARY KEY CLUSTERED ([Cmp_ID] ASC) WITH (FILLFACTOR = 95)
);

