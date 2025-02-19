CREATE TABLE [dbo].[T0055_JobSkill] (
    [Job_Skill_Id] NUMERIC (18) NOT NULL,
    [Cmp_Id]       NUMERIC (18) NOT NULL,
    [Job_Id]       NUMERIC (18) NOT NULL,
    [Skill_Id]     NUMERIC (18) NOT NULL,
    [Mandatory]    BIT          CONSTRAINT [DF_T0055_JobSkill_Mandatory] DEFAULT ((0)) NOT NULL,
    [Secondary]    BIT          CONSTRAINT [DF_T0055_JobSkill_Secondary] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0055_JobSkill] PRIMARY KEY CLUSTERED ([Job_Skill_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_JobSkill_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_JobSkill_T0040_SKILL_MASTER] FOREIGN KEY ([Skill_Id]) REFERENCES [dbo].[T0040_SKILL_MASTER] ([Skill_ID]),
    CONSTRAINT [FK_T0055_JobSkill_T0050_JobDescription_Master] FOREIGN KEY ([Job_Id]) REFERENCES [dbo].[T0050_JobDescription_Master] ([Job_Id])
);

