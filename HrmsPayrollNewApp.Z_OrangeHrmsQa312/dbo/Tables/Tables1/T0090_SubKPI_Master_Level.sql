CREATE TABLE [dbo].[T0090_SubKPI_Master_Level] (
    [Row_Id]    NUMERIC (18)    NOT NULL,
    [Cmp_Id]    NUMERIC (18)    NOT NULL,
    [Tran_Id]   NUMERIC (18)    NOT NULL,
    [KPI_Id]    NUMERIC (18)    NULL,
    [Sub_KPI]   VARCHAR (250)   NULL,
    [Weightage] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0090_SubKPI_Master_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_SubKPI_Master_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_SubKPI_Master_Level_T0040_KPI_Master] FOREIGN KEY ([KPI_Id]) REFERENCES [dbo].[T0040_KPI_Master] ([KPI_Id]),
    CONSTRAINT [FK_T0090_SubKPI_Master_Level_T0090_EmpKPI_Approval] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0090_EmpKPI_Approval] ([Tran_Id])
);

