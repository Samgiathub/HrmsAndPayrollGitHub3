CREATE TABLE [dbo].[T0055_RecruitmentSkill] (
    [Rec_Skill_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]       NUMERIC (18)  NOT NULL,
    [Rec_Req_ID]   NUMERIC (18)  NOT NULL,
    [Skill_Id]     NUMERIC (18)  NOT NULL,
    [Mandatory]    BIT           CONSTRAINT [DF_T0055_RecruitmentSkill_Mandatory] DEFAULT ((0)) NOT NULL,
    [Secondary]    BIT           CONSTRAINT [DF_T0055_RecruitmentSkill_Secondary] DEFAULT ((0)) NOT NULL,
    [Comments]     VARCHAR (MAX) DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_T0055_RecruitmentSkill] PRIMARY KEY CLUSTERED ([Rec_Skill_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_RecruitmentSkill_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_RecruitmentSkill_T0040_SKILL_MASTER] FOREIGN KEY ([Skill_Id]) REFERENCES [dbo].[T0040_SKILL_MASTER] ([Skill_ID]),
    CONSTRAINT [FK_T0055_RecruitmentSkill_T0050_HRMS_Recruitment_Request] FOREIGN KEY ([Rec_Req_ID]) REFERENCES [dbo].[T0050_HRMS_Recruitment_Request] ([Rec_Req_ID])
);

