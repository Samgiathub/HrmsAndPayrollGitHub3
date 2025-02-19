CREATE TABLE [dbo].[T0100_KPI_DevelopmentPlan_Level] (
    [Row_Id]            NUMERIC (18)  NOT NULL,
    [Cmp_Id]            NUMERIC (18)  NOT NULL,
    [Tran_Id]           NUMERIC (18)  NULL,
    [Strengths]         VARCHAR (200) NULL,
    [DevelopmentAreas]  VARCHAR (200) NULL,
    [ImprovementAction] VARCHAR (200) NULL,
    [Timeline]          VARCHAR (200) NULL,
    [Status]            VARCHAR (200) NULL,
    CONSTRAINT [PK_T0100_KPI_DevelopmentPlan_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_KPI_DevelopmentPlan_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_KPI_DevelopmentPlan_Level_T0090_KPIPMS_EVAL_Approval] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0090_KPIPMS_EVAL_Approval] ([Tran_Id])
);

