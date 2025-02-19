CREATE TABLE [dbo].[T0140_HRMS_TRAINING_Feedback] (
    [Tran_feedback_ID]   NUMERIC (18)    NOT NULL,
    [Tran_emp_Detail_ID] NUMERIC (18)    NOT NULL,
    [cmp_id]             NUMERIC (18)    NOT NULL,
    [is_attend]          INT             NULL,
    [Reason]             VARCHAR (500)   NULL,
    [emp_score]          NUMERIC (18, 2) NULL,
    [emp_comments]       VARCHAR (500)   NULL,
    [emp_suggestion]     VARCHAR (500)   NULL,
    [sup_score]          NUMERIC (18, 2) NULL,
    [sup_comments]       VARCHAR (500)   NULL,
    [sup_suggestion]     VARCHAR (500)   NULL,
    [emp_s_id]           NUMERIC (18)    NULL,
    [status]             INT             NULL,
    CONSTRAINT [PK_T0140_HRMS_TRAINING_Feedback] PRIMARY KEY CLUSTERED ([Tran_feedback_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0140_HRMS_TRAINING_Feedback_T0010_COMPANY_MASTER1] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0140_HRMS_TRAINING_Feedback_T0080_EMP_MASTER1] FOREIGN KEY ([emp_s_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0140_HRMS_TRAINING_Feedback_T0130_HRMS_TRAINING_EMPLOYEE_DETAIL1] FOREIGN KEY ([Tran_emp_Detail_ID]) REFERENCES [dbo].[T0130_HRMS_TRAINING_EMPLOYEE_DETAIL] ([Tran_emp_Detail_ID])
);

