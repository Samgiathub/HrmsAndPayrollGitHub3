CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_GoalDescription] (
    [GoalDescription_Id]          NUMERIC (18)   NOT NULL,
    [FK_GoalId]                   NUMERIC (18)   NOT NULL,
    [GoalDescription_CmpId]       NUMERIC (18)   NOT NULL,
    [GoalDescription]             VARCHAR (1000) NOT NULL,
    [SuccessCriteria]             VARCHAR (1000) NOT NULL,
    [FK_GoalType]                 NUMERIC (18)   NULL,
    [AbovePar]                    VARCHAR (500)  NULL,
    [AtPar]                       VARCHAR (500)  NULL,
    [BelowPar]                    VARCHAR (500)  NULL,
    [Employee_Comment]            VARCHAR (1000) NULL,
    [Supervisor_Comment]          VARCHAR (1000) NULL,
    [FK_Rating]                   NUMERIC (18)   NULL,
    [FK_EmployeeId]               NUMERIC (18)   NULL,
    [FK_SupervisorId]             NUMERIC (18)   NULL,
    [GoalDescription_Year]        NUMERIC (18)   NULL,
    [GoalDescription_CreatedBy]   NUMERIC (18)   NOT NULL,
    [GoalDescription_CreatedDate] DATETIME       NOT NULL,
    [GoalDescription_ModifyBy]    NUMERIC (18)   NULL,
    [GoalDescription_ModifyDate]  DATETIME       NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_GoalDescription] PRIMARY KEY CLUSTERED ([GoalDescription_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_GoalDescription_T0090_HRMS_Appraisal_Emp_Goal] FOREIGN KEY ([FK_GoalId]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_Goal] ([Goal_Id])
);

