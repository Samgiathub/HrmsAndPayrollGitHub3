CREATE TABLE [dbo].[T0040_Training_Skill_Master] (
    [Skill_ID]      NUMERIC (18)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NULL,
    [Skill_Name]    VARCHAR (100) NULL,
    [Skill_Sort_ID] NUMERIC (5)   NULL,
    [Modify_Date]   DATETIME      NULL,
    [Modify_By]     NUMERIC (18)  NULL,
    [Ip_Address]    VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([Skill_ID] ASC)
);

