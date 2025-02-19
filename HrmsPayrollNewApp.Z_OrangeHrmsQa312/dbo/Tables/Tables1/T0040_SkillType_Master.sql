CREATE TABLE [dbo].[T0040_SkillType_Master] (
    [SkillType_ID] INT           NOT NULL,
    [cmp_ID]       INT           CONSTRAINT [DF_T0040_SkillType_Master_cmp_ID] DEFAULT ((0)) NOT NULL,
    [Skill_Name]   VARCHAR (50)  NULL,
    [Description]  VARCHAR (MAX) NULL
);

