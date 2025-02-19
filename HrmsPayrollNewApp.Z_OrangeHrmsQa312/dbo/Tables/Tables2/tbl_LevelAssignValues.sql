CREATE TABLE [dbo].[tbl_LevelAssignValues] (
    [la_Id]            INT IDENTITY (1, 1) NOT NULL,
    [la_AllotmentId]   INT NULL,
    [la_LevelAssignId] INT NULL,
    [la_LevelId]       INT NULL,
    [la_LevelValue]    INT NULL,
    [la_SectionId]     INT NULL,
    [la_GoalId]        INT NULL,
    [la_SubGoalId]     INT NULL,
    [la_LvlGrpId]      INT NULL,
    [Cmp_Id]           INT NULL,
    CONSTRAINT [PK_tbl_LevelAssignValues] PRIMARY KEY CLUSTERED ([la_Id] ASC) WITH (FILLFACTOR = 95)
);

