CREATE TABLE [dbo].[T0100_KPIObjectives_Level] (
    [Row_Id]    NUMERIC (18)  NOT NULL,
    [Cmp_Id]    NUMERIC (18)  NOT NULL,
    [Tran_Id]   NUMERIC (18)  NOT NULL,
    [KpiAtt_Id] NUMERIC (18)  NULL,
    [Objective] VARCHAR (MAX) NULL,
    [Metric]    VARCHAR (500) NULL,
    CONSTRAINT [PK_T0100_KPIObjectives_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_KPIObjectives_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_KPIObjectives_Level_T0090_EmpKPI_Approval] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0090_EmpKPI_Approval] ([Tran_Id]),
    CONSTRAINT [FK_T0100_KPIObjectives_Level_T0100_EMpKPI_Master_Level] FOREIGN KEY ([KpiAtt_Id]) REFERENCES [dbo].[T0040_EmpKPI_Master] ([KpiAtt_Id])
);

