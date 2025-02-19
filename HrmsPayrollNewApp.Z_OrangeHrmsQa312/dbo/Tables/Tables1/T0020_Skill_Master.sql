CREATE TABLE [dbo].[T0020_Skill_Master] (
    [Skill_Id]    NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NOT NULL,
    [Skill_Name]  VARCHAR (50)    NOT NULL,
    [Description] VARCHAR (50)    NOT NULL,
    [Year_1]      NUMERIC (18, 1) NOT NULL,
    CONSTRAINT [PK_T0020_Skill_Master] PRIMARY KEY CLUSTERED ([Skill_Id] ASC) WITH (FILLFACTOR = 80)
);

