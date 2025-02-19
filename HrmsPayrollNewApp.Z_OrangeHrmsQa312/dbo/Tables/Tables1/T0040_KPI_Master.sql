CREATE TABLE [dbo].[T0040_KPI_Master] (
    [KPI_Id]         NUMERIC (18)    NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Branch_Id]      VARCHAR (MAX)   NULL,
    [KPI]            VARCHAR (250)   NULL,
    [Weightage]      NUMERIC (18, 2) NULL,
    [Effective_Date] DATETIME        NULL,
    [Category_Id]    NUMERIC (18)    NULL,
    [Designation_Id] VARCHAR (MAX)   NULL,
    [Active]         BIT             NULL,
    CONSTRAINT [PK_T0040_KPI_Master] PRIMARY KEY CLUSTERED ([KPI_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_KPI_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_KPI_Master_T0030_CATEGORY_MASTER] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[T0030_CATEGORY_MASTER] ([Cat_ID])
);

