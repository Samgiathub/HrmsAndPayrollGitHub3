CREATE TABLE [dbo].[kpms_FrqWise_Target_Achievement] (
    [fta_id]             INT           IDENTITY (1, 1) NOT NULL,
    [freq_id]            INT           NULL,
    [Month]              VARCHAR (MAX) NULL,
    [Achievement]        INT           NULL,
    [emp_id]             INT           NULL,
    [Achievement_id]     VARCHAR (500) NULL,
    [TargetAchiveid]     INT           NULL,
    [Actual_Achievement] INT           NULL,
    [levelAssignid]      INT           NULL,
    [Cmp_Id]             INT           NULL
);

