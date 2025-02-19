CREATE TABLE [dbo].[T0090_PerformanceImprovementPlan] (
    [Emp_PIP_Id]   NUMERIC (18) NOT NULL,
    [Cmp_Id]       NUMERIC (18) NOT NULL,
    [Emp_Id]       NUMERIC (18) NOT NULL,
    [PIP_Status]   INT          NULL,
    [FinYear]      INT          NULL,
    [CreatedDate]  DATETIME     NULL,
    [ModifiedDate] DATETIME     NULL,
    [StartDate]    DATETIME     NOT NULL,
    [Enddate]      DATETIME     NOT NULL,
    CONSTRAINT [PK_T0090_PerformanceImprovementPlan] PRIMARY KEY CLUSTERED ([Emp_PIP_Id] ASC),
    CONSTRAINT [FK_T0090_PerformanceImprovementPlan_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_PerformanceImprovementPlan_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

