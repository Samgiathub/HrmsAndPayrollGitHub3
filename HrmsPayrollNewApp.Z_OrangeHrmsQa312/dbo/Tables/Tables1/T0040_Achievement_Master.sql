CREATE TABLE [dbo].[T0040_Achievement_Master] (
    [AchievementId]     NUMERIC (18) NOT NULL,
    [Cmp_ID]            NUMERIC (18) NOT NULL,
    [Achievement_Level] VARCHAR (50) NOT NULL,
    [Achievement_Sort]  INT          NULL,
    [Achievement_Type]  INT          NULL,
    [Effective_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0040_Achievement_Master] PRIMARY KEY CLUSTERED ([AchievementId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Achievement_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

