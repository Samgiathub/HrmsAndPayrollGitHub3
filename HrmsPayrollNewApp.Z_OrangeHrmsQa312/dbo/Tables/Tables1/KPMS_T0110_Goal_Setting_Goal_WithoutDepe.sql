CREATE TABLE [dbo].[KPMS_T0110_Goal_Setting_Goal_WithoutDepe] (
    [GSG_Id]                    INT IDENTITY (1, 1) NOT NULL,
    [GSG_GoalSetting_Id]        INT NULL,
    [GSG_GoalSettingSection_Id] INT NULL,
    [GSG_Goal_Id]               INT NULL,
    [GSG_Sub_Goal_Id]           INT NULL,
    [GSG_FrequecyId]            INT NULL,
    [GSG_WeightageType_Id]      INT NULL,
    [GSG_WeightageValue]        INT NULL,
    [GSG_StatusId]              INT NULL,
    [GSG_IsDependency]          BIT NULL,
    [GSG_Depend_Goal_Id]        INT NULL,
    [GSG_Depend_Type_Id]        INT NULL,
    [GSG_DependValue]           INT NULL,
    [Cmp_Id]                    INT NULL
);

