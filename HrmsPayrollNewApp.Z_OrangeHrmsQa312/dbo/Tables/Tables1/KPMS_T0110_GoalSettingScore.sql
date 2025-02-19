CREATE TABLE [dbo].[KPMS_T0110_GoalSettingScore] (
    [GSB_Id]            INT          IDENTITY (1, 1) NOT NULL,
    [GSB_GoalSettingId] INT          NULL,
    [GSB_Title]         VARCHAR (50) NULL,
    [GSB_Min]           FLOAT (53)   NULL,
    [GSB_Max]           FLOAT (53)   NULL,
    [Cmp_Id]            INT          NULL,
    CONSTRAINT [PK_KPMS_T0110_GoalSettingScore] PRIMARY KEY CLUSTERED ([GSB_Id] ASC) WITH (FILLFACTOR = 95)
);

