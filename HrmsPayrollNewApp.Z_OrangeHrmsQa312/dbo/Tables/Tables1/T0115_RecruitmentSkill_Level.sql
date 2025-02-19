CREATE TABLE [dbo].[T0115_RecruitmentSkill_Level] (
    [Row_Id]    NUMERIC (18) NOT NULL,
    [Cmp_Id]    NUMERIC (18) NOT NULL,
    [RecApp_Id] NUMERIC (18) NOT NULL,
    [Skill_Id]  NUMERIC (18) NOT NULL,
    [Mandatory] BIT          CONSTRAINT [DF_T0115_RecruitmentSkill_Level_Mandatory] DEFAULT ((0)) NOT NULL,
    [Secondary] BIT          CONSTRAINT [DF_T0115_RecruitmentSkill_Level_Secondary] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0115_RecruitmentSkill_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0115_RecruitmentSkill_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_RecruitmentSkill_Level_T0052_Hrms_RecruitmentRequest_Approval] FOREIGN KEY ([RecApp_Id]) REFERENCES [dbo].[T0052_Hrms_RecruitmentRequest_Approval] ([RecApp_Id])
);

