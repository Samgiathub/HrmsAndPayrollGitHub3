CREATE TABLE [dbo].[KPMS_T0100_Level_Assign] (
    [level_assign_Id]   INT           IDENTITY (1, 1) NOT NULL,
    [SectionId]         INT           NULL,
    [GoalId]            INT           NULL,
    [SubGoalId]         INT           NULL,
    [WeightageType]     INT           NULL,
    [TargetValues]      INT           NULL,
    [LevelValues]       VARCHAR (MAX) NULL,
    [LevlGrpValues]     VARCHAR (MAX) NULL,
    [GoalSettingId]     INT           NULL,
    [GoalSheet_Id]      INT           NULL,
    [Goal_Allotment_Id] INT           NULL,
    [Cmp_Id]            INT           NULL,
    CONSTRAINT [PK_KPMS_T0100_Level_Assign] PRIMARY KEY CLUSTERED ([level_assign_Id] ASC) WITH (FILLFACTOR = 95)
);

