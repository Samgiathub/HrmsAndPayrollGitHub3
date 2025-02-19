CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_Goal] (
    [Goal_Id]                NUMERIC (18)   NOT NULL,
    [Goal_CmpId]             NUMERIC (18)   NOT NULL,
    [Goal_Title]             VARCHAR (200)  NOT NULL,
    [FK_GoalType]            NUMERIC (18)   NOT NULL,
    [Employee_Comment]       VARCHAR (1000) NULL,
    [Employee_SignOff]       TINYINT        NULL,
    [Employee_SignOffDate]   DATETIME       NULL,
    [Supervisor_Comment]     VARCHAR (1000) NULL,
    [Supervisor_SignOff]     TINYINT        NULL,
    [Supervisor_SignOffDate] DATETIME       NULL,
    [FK_EmployeeId]          NUMERIC (18)   NULL,
    [FK_SupervisorId]        NUMERIC (18)   NULL,
    [Goal_StartDate]         DATETIME       NULL,
    [Goal_EndDate]           DATETIME       NULL,
    [Goal_Year]              NUMERIC (18)   NULL,
    [Goal_CreatedBy]         NUMERIC (18)   NOT NULL,
    [Goal_CreatedDate]       DATETIME       NOT NULL,
    [Goal_ModifyBy]          NUMERIC (18)   NULL,
    [Goal_ModifyDate]        DATETIME       NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_Goal] PRIMARY KEY CLUSTERED ([Goal_Id] ASC) WITH (FILLFACTOR = 80)
);

