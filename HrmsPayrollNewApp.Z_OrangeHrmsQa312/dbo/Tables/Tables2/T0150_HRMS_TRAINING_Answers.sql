CREATE TABLE [dbo].[T0150_HRMS_TRAINING_Answers] (
    [Tran_Answer_ID]        NUMERIC (18)   NOT NULL,
    [Tran_Feedback_Id]      NUMERIC (18)   NULL,
    [Tran_Emp_Detail_Id]    NUMERIC (18)   NULL,
    [Tran_Question_Id]      NUMERIC (18)   NOT NULL,
    [Answer]                NVARCHAR (500) NOT NULL,
    [Cmp_Id]                NUMERIC (18)   NOT NULL,
    [Create_Date]           DATETIME       NOT NULL,
    [emp_Id]                NUMERIC (18)   NULL,
    [Training_id]           NUMERIC (18)   NULL,
    [Training_Apr_ID]       NUMERIC (18)   NULL,
    [Training_Induction_ID] NUMERIC (18)   NULL,
    CONSTRAINT [PK_T0150_HRMS_TRAINING_Answers] PRIMARY KEY CLUSTERED ([Tran_Answer_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0150_HRMS_TRAINING_Answers_T0040_Hrms_Training_MASTER] FOREIGN KEY ([Training_id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0150_HRMS_TRAINING_Answers_T0080_EMP_MASTER] FOREIGN KEY ([emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0150_HRMS_TRAINING_Answers_T0120_HRMS_TRAINING_APPROVAL] FOREIGN KEY ([Training_Apr_ID]) REFERENCES [dbo].[T0120_HRMS_TRAINING_APPROVAL] ([Training_Apr_ID]),
    CONSTRAINT [FK_T0150_HRMS_TRAINING_Answers_T0150_HRMS_TRAINING_Questionnaire] FOREIGN KEY ([Tran_Question_Id]) REFERENCES [dbo].[T0150_HRMS_TRAINING_Questionnaire] ([Training_Que_ID])
);

