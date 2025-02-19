CREATE TABLE [dbo].[T0052_Increment_Utility] (
    [Increment_Utility_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]               NUMERIC (18)    NOT NULL,
    [EffectiveDate]        DATETIME        NOT NULL,
    [Segment_ID]           NUMERIC (18)    NULL,
    [Grd_Id]               NUMERIC (18)    NULL,
    [desig_Id]             NUMERIC (18)    NULL,
    [Branch_Id]            NUMERIC (18)    NULL,
    [dept_Id]              NUMERIC (18)    NULL,
    [Amount]               NUMERIC (18, 2) NULL,
    [Achivement_Id]        NUMERIC (18)    NULL,
    [Percentage]           NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0052_Increment_Utility] PRIMARY KEY CLUSTERED ([Increment_Utility_Id] ASC),
    CONSTRAINT [FK_T0052_Increment_Utility_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_Id]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0040_Achievement_Master] FOREIGN KEY ([Achivement_Id]) REFERENCES [dbo].[T0040_Achievement_Master] ([AchievementId]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0040_Business_Segment] FOREIGN KEY ([Segment_ID]) REFERENCES [dbo].[T0040_Business_Segment] ([Segment_ID]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([dept_Id]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0040_DESIGNATION_MASTER] FOREIGN KEY ([desig_Id]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0052_Increment_Utility_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_Id]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID])
);

