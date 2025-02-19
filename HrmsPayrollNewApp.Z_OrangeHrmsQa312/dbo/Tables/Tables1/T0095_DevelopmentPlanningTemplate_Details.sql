CREATE TABLE [dbo].[T0095_DevelopmentPlanningTemplate_Details] (
    [Emp_DPT_Detail_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [Emp_Id]            NUMERIC (18)   NOT NULL,
    [Emp_DPT_Id]        NUMERIC (18)   NOT NULL,
    [DevelopmentArea]   VARCHAR (300)  NULL,
    [Action_Target]     NVARCHAR (100) NULL,
    [Start_Date]        DATETIME       NULL,
    [End_Date]          DATETIME       NULL,
    [Resources]         VARCHAR (100)  NULL,
    [Emp_Feedback]      VARCHAR (200)  NULL,
    [Manager_Feedback]  VARCHAR (200)  NULL,
    CONSTRAINT [PK_T0095_DevelopmentPlanningTemplate_Details] PRIMARY KEY CLUSTERED ([Emp_DPT_Detail_Id] ASC),
    CONSTRAINT [FK_T0095_DevelopmentPlanningTemplate_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_DevelopmentPlanningTemplate_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0095_DevelopmentPlanningTemplate_Details_T0090_DevelopmentPlanningTemplate] FOREIGN KEY ([Emp_DPT_Id]) REFERENCES [dbo].[T0090_DevelopmentPlanningTemplate] ([Emp_DPT_Id])
);

