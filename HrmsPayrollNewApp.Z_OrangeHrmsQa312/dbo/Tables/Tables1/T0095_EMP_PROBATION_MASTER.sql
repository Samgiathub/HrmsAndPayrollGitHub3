﻿CREATE TABLE [dbo].[T0095_EMP_PROBATION_MASTER] (
    [Probation_Evaluation_ID]    NUMERIC (18)    NOT NULL,
    [Emp_ID]                     NUMERIC (18)    NOT NULL,
    [Cmp_ID]                     NUMERIC (18)    NOT NULL,
    [Probation_Status]           NUMERIC (18)    NOT NULL,
    [Evaluation_Date]            DATETIME        NOT NULL,
    [Extend_Period]              NUMERIC (18, 2) NULL,
    [Old_Probation_Period]       NUMERIC (18, 2) NOT NULL,
    [Old_Probation_EndDate]      DATETIME        NULL,
    [New_Probation_EndDate]      DATETIME        NULL,
    [Major_Strength]             VARCHAR (1500)  NULL,
    [Major_Weakness]             VARCHAR (1500)  NULL,
    [Appraiser_Remarks]          NVARCHAR (500)  NULL,
    [Appraisal_Reviewer_Remarks] NVARCHAR (500)  NULL,
    [Supervisor_ID]              NUMERIC (18)    NOT NULL,
    [Flag]                       VARCHAR (10)    NULL,
    [Training_ID]                VARCHAR (MAX)   NULL,
    [Approval_Period_Type]       VARCHAR (50)    NULL,
    [Emp_Type_Id]                NUMERIC (18)    NULL,
    [Final_Review]               NUMERIC (18)    NULL,
    [Review_Type]                VARCHAR (15)    NULL,
    [Attach_Docs]                VARCHAR (MAX)   DEFAULT ('') NOT NULL,
    [Confirmation_date]          DATETIME        NULL,
    CONSTRAINT [PK_T0095_EMP_PROBATION_MASTER] PRIMARY KEY CLUSTERED ([Probation_Evaluation_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0095_EMP_PROBATION_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_EMP_PROBATION_MASTER_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

