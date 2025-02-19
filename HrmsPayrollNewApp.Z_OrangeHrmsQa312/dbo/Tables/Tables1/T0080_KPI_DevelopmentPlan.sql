CREATE TABLE [dbo].[T0080_KPI_DevelopmentPlan] (
    [KPI_DevelopmentID] NUMERIC (18)  NOT NULL,
    [Cmp_Id]            NUMERIC (18)  NOT NULL,
    [KPIPMS_ID]         NUMERIC (18)  NULL,
    [Emp_ID]            NUMERIC (18)  NULL,
    [Strengths]         VARCHAR (200) NULL,
    [DevelopmentAreas]  VARCHAR (200) NULL,
    [ImprovementAction] VARCHAR (200) NULL,
    [Timeline]          VARCHAR (200) NULL,
    [Status]            VARCHAR (200) NULL,
    CONSTRAINT [PK_T0080_KPI_DevelopmentPlan] PRIMARY KEY CLUSTERED ([KPI_DevelopmentID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0080_KPI_DevelopmentPlan_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0080_KPI_DevelopmentPlan_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0080_KPI_DevelopmentPlan_T0080_KPIPMS_EVAL] FOREIGN KEY ([KPIPMS_ID]) REFERENCES [dbo].[T0080_KPIPMS_EVAL] ([KPIPMS_ID])
);

