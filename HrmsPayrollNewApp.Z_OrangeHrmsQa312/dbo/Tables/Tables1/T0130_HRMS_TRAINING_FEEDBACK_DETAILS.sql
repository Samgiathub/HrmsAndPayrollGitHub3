CREATE TABLE [dbo].[T0130_HRMS_TRAINING_FEEDBACK_DETAILS] (
    [Training_Apr_Detail_ID] NUMERIC (18)    NOT NULL,
    [Training_Apr_ID]        NUMERIC (18)    NOT NULL,
    [Emp_ID]                 NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NOT NULL,
    [Emp_S_ID]               NUMERIC (18)    NOT NULL,
    [Emp_Feedback]           VARCHAR (1000)  NULL,
    [Superior_Feedback]      VARCHAR (1000)  NULL,
    [Emp_Feedback_Date]      DATETIME        NULL,
    [Sup_feedback_date]      DATETIME        NULL,
    [Emp_Eval_Rate]          NUMERIC (18, 2) NULL,
    [Sup_Eval_Rate]          NUMERIC (18, 2) NULL,
    [Is_Attend]              CHAR (1)        NOT NULL,
    CONSTRAINT [PK_T0130_HRMS_TRAINING_FEEDBACK_DETAILS] PRIMARY KEY CLUSTERED ([Training_Apr_Detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_HRMS_TRAINING_FEEDBACK_DETAILS_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

