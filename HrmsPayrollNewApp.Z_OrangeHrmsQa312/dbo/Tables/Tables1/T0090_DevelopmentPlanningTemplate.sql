CREATE TABLE [dbo].[T0090_DevelopmentPlanningTemplate] (
    [Emp_DPT_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]          NUMERIC (18)  NOT NULL,
    [Emp_Id]          NUMERIC (18)  NOT NULL,
    [DPT_Status]      INT           NULL,
    [FinYear]         INT           NULL,
    [Emp_Comment]     VARCHAR (300) NULL,
    [Manager_Comment] VARCHAR (300) NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedDate]    DATETIME      NULL,
    [StartDate]       DATETIME      NOT NULL,
    [Enddate]         DATETIME      NOT NULL,
    CONSTRAINT [PK_T0090_DevelopmentPlanningTemplate] PRIMARY KEY CLUSTERED ([Emp_DPT_Id] ASC),
    CONSTRAINT [FK_T0090_DevelopmentPlanningTemplate_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_DevelopmentPlanningTemplate_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

