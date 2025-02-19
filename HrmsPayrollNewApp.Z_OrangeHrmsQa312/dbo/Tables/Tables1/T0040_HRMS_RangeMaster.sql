CREATE TABLE [dbo].[T0040_HRMS_RangeMaster] (
    [Range_ID]               NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NULL,
    [Range_From]             NUMERIC (18, 2) NULL,
    [Range_To]               NUMERIC (18, 2) NULL,
    [Range_Type]             INT             NULL,
    [Range_Level]            VARCHAR (50)    NULL,
    [Range_Dept]             VARCHAR (800)   NULL,
    [Range_Grade]            VARCHAR (800)   NULL,
    [Range_PID]              NUMERIC (18)    NULL,
    [Range_Percent_Allocate] NUMERIC (18, 2) NULL,
    [Range_AchievementId]    NUMERIC (18)    NULL,
    [Effective_Date]         DATETIME        NULL,
    CONSTRAINT [PK_T0040_HRMS_RangeMaster] PRIMARY KEY CLUSTERED ([Range_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_HRMS_RangeMaster_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_HRMS_RangeMaster_T0040_Achievement_Master] FOREIGN KEY ([Range_AchievementId]) REFERENCES [dbo].[T0040_Achievement_Master] ([AchievementId])
);

