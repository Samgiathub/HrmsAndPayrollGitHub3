CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_PerformanceSummary] (
    [PS_Id]                  NUMERIC (18)  NOT NULL,
    [PS_CmpId]               NUMERIC (18)  NOT NULL,
    [PS_EmployeeComment]     VARCHAR (500) NULL,
    [PS_SupervisorComment]   VARCHAR (500) NULL,
    [Cp_EmployeeComment]     VARCHAR (500) NULL,
    [Cp_SupervisorComment]   VARCHAR (500) NULL,
    [FK_Rating]              NUMERIC (18)  NULL,
    [FK_EmployeeId]          NUMERIC (18)  NULL,
    [FK_SupervisorId]        NUMERIC (18)  NULL,
    [Employee_SignOff]       TINYINT       NULL,
    [Employee_SignOffDate]   DATETIME      NULL,
    [Supervisor_SignOff]     TINYINT       NULL,
    [Supervisor_SignOffDate] DATETIME      NULL,
    [PS_StartDate]           DATETIME      NULL,
    [PS_EndDate]             DATETIME      NULL,
    [PS_Year]                NUMERIC (18)  NOT NULL,
    [PS_CreatedBy]           NUMERIC (18)  NOT NULL,
    [PS_CreatedDate]         DATETIME      NOT NULL,
    [PS_ModifyBy]            NUMERIC (18)  NULL,
    [PS_ModifyDate]          DATETIME      NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_PerformanceSummary] PRIMARY KEY CLUSTERED ([PS_Id] ASC) WITH (FILLFACTOR = 80)
);

