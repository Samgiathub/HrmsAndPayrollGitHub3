CREATE TABLE [dbo].[T0040_HRMS_Appraisal_GoalType_Master] (
    [GoalType_Id]          NUMERIC (18)  NOT NULL,
    [GoalType_CmpId]       NUMERIC (18)  NOT NULL,
    [GoalType]             VARCHAR (100) NOT NULL,
    [GoalType_IsActive]    TINYINT       NOT NULL,
    [GoalType_CreatedBy]   NUMERIC (18)  NOT NULL,
    [GoalType_CreatedDate] DATETIME      NOT NULL,
    [GoalType_ModifyBy]    NUMERIC (18)  NULL,
    [GoalType_ModifyDate]  DATETIME      NULL,
    CONSTRAINT [PK_T0040_HRMS_Appraisal_GoalType_Master] PRIMARY KEY CLUSTERED ([GoalType_Id] ASC) WITH (FILLFACTOR = 80)
);

