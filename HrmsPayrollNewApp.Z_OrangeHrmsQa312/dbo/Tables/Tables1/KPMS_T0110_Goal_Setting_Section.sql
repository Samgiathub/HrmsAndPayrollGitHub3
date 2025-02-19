CREATE TABLE [dbo].[KPMS_T0110_Goal_Setting_Section] (
    [GSS_Id]              INT IDENTITY (1, 1) NOT NULL,
    [GSS_Goal_Setting_Id] INT NULL,
    [GSS_SectionId]       INT NULL,
    [GSS_WeightageTypeId] INT NULL,
    [GSS_WeightageValue]  INT NULL,
    [GSS_StatusId]        INT NULL,
    [GSS_MonthId]         INT NULL,
    [Cmp_Id]              INT NULL,
    [sectionIndex]        INT NULL,
    CONSTRAINT [PK_KPMS_T0110_Goal_Setting_Section] PRIMARY KEY CLUSTERED ([GSS_Id] ASC) WITH (FILLFACTOR = 95)
);

