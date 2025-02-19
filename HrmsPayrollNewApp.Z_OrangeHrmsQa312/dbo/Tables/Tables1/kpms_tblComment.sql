CREATE TABLE [dbo].[kpms_tblComment] (
    [commid]       INT           IDENTITY (1, 1) NOT NULL,
    [Eid]          INT           NULL,
    [comment]      VARCHAR (200) NULL,
    [GoalSheet_Id] INT           NULL,
    [date]         VARCHAR (50)  NULL,
    [goalAlt_id]   INT           NULL,
    [Cmp_Id]       INT           NULL
);

