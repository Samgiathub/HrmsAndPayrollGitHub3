CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_SOLAssessment] (
    [SOLAssessment_Id]          NUMERIC (18) NOT NULL,
    [SOLAssessment_CmpId]       NUMERIC (18) NOT NULL,
    [FK_EmployeeId]             NUMERIC (18) NULL,
    [FK_SupervisorId]           NUMERIC (18) NULL,
    [Employee_SignOff]          TINYINT      NULL,
    [Employee_SignOffDate]      DATETIME     NULL,
    [Supervisor_SignOff]        TINYINT      NULL,
    [Supervisor_SignOffDate]    DATETIME     NULL,
    [SOLAssessment_StartDate]   DATETIME     NULL,
    [SOLAssessment_EndDate]     DATETIME     NULL,
    [SOLAssessment_Year]        NUMERIC (18) NULL,
    [SOLAssessment_CreatedBy]   NUMERIC (18) NOT NULL,
    [SOLAssessment_CreatedDate] DATETIME     NOT NULL,
    [SOLAssessment_ModifyBy]    NUMERIC (18) NULL,
    [SOLAssessment_ModifyDate]  DATETIME     NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_SOLAssessment] PRIMARY KEY CLUSTERED ([SOLAssessment_Id] ASC) WITH (FILLFACTOR = 80)
);

