CREATE TABLE [dbo].[T0040_Collection_Master] (
    [Collection_ID]        NUMERIC (18)    NOT NULL,
    [CollectionMonth]      VARCHAR (50)    NULL,
    [CollectionYear]       NUMERIC (18)    NULL,
    [Project_ID]           NUMERIC (18)    NULL,
    [Service_Type]         VARCHAR (50)    NULL,
    [Contract_Type]        VARCHAR (50)    NULL,
    [Practice_Collection]  NUMERIC (18, 2) NULL,
    [Charges_Per]          NUMERIC (18, 2) NULL,
    [Fedora_Charges]       NUMERIC (18, 2) NULL,
    [Exchange_Rate]        NUMERIC (18, 2) NULL,
    [Total_Fedora_Charges] NUMERIC (18, 2) NULL,
    [Other_Remarks]        VARCHAR (100)   NULL,
    [Cmp_ID]               NUMERIC (18)    NULL,
    [Created_By]           NUMERIC (18)    NULL,
    [Created_Date]         DATETIME        NULL,
    [Modify_By]            NUMERIC (18)    NULL,
    [Modify_Date]          DATETIME        NULL,
    [Manager_ID]           NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0040_Collection_Master] PRIMARY KEY CLUSTERED ([Collection_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Collection_Master_T0040_TS_Project_Master] FOREIGN KEY ([Project_ID]) REFERENCES [dbo].[T0040_TS_Project_Master] ([Project_ID])
);

