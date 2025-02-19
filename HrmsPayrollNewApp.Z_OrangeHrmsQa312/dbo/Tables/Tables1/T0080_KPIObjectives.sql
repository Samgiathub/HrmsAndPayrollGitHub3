CREATE TABLE [dbo].[T0080_KPIObjectives] (
    [KPIObj_ID]           NUMERIC (18)  NOT NULL,
    [Cmp_Id]              NUMERIC (18)  NOT NULL,
    [KpiAtt_Id]           NUMERIC (18)  NOT NULL,
    [Objective]           VARCHAR (MAX) NULL,
    [Emp_ID]              NUMERIC (18)  NOT NULL,
    [CreatedBy_ID]        NUMERIC (18)  NOT NULL,
    [AddByFlag]           CHAR (1)      NULL,
    [Approve_Status]      CHAR (1)      NULL,
    [Verification_Status] CHAR (1)      NULL,
    [EmpKPI_Id]           NUMERIC (18)  NULL,
    [Metric]              VARCHAR (500) NULL,
    CONSTRAINT [PK_T0080_KPIObjectives] PRIMARY KEY CLUSTERED ([KPIObj_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0080_KPIObjectives_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0080_KPIObjectives_T0040_EmpKPI_Master] FOREIGN KEY ([KpiAtt_Id]) REFERENCES [dbo].[T0040_EmpKPI_Master] ([KpiAtt_Id]),
    CONSTRAINT [FK_T0080_KPIObjectives_T0080_EmpKPI1] FOREIGN KEY ([EmpKPI_Id]) REFERENCES [dbo].[T0080_EmpKPI] ([EmpKPI_Id])
);

