CREATE TABLE [dbo].[T0095_PerformanceImprovementPlan_Details] (
    [Emp_PIP_Detail_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [Emp_Id]            NUMERIC (18)   NOT NULL,
    [Emp_PIP_Id]        NUMERIC (18)   NOT NULL,
    [ImprovementArea]   VARCHAR (300)  NULL,
    [Target]            NVARCHAR (100) NULL,
    [Start_Date]        DATETIME       NULL,
    [End_Date]          DATETIME       NULL,
    [Emp_Feedback]      NVARCHAR (200) NULL,
    [Manager_Feedback]  NVARCHAR (200) NULL,
    CONSTRAINT [PK_T0095_PerformanceImprovementPlan_Details] PRIMARY KEY CLUSTERED ([Emp_PIP_Detail_Id] ASC),
    CONSTRAINT [FK_T0095_PerformanceImprovementPlan_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_PerformanceImprovementPlan_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0095_PerformanceImprovementPlan_Details_T0090_PerformanceImprovementPlan] FOREIGN KEY ([Emp_PIP_Id]) REFERENCES [dbo].[T0090_PerformanceImprovementPlan] ([Emp_PIP_Id])
);

