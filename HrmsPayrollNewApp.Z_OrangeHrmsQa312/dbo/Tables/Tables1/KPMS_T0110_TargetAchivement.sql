CREATE TABLE [dbo].[KPMS_T0110_TargetAchivement] (
    [TargetAchiveid]  INT           IDENTITY (1, 1) NOT NULL,
    [sectionid]       INT           NULL,
    [goalid]          INT           NULL,
    [subgoalid]       INT           NULL,
    [targetvalue]     INT           NOT NULL,
    [Freq_id]         INT           NULL,
    [emp_id]          INT           NOT NULL,
    [R_Emp_ID]        INT           NULL,
    [Scheme_ID]       INT           NULL,
    [goalAlt_id]      INT           NULL,
    [WeightageType]   INT           NULL,
    [Achievement]     INT           NULL,
    [Month]           VARCHAR (MAX) NULL,
    [levelAssignid]   INT           NULL,
    [Actual_Target]   INT           NULL,
    [Cmp_Id]          INT           NULL,
    [Month_Num]       VARCHAR (MAX) NULL,
    [goal_setting_ID] INT           NULL
);

