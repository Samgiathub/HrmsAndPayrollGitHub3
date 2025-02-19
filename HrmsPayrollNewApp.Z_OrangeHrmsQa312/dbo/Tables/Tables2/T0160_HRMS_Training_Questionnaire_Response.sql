CREATE TABLE [dbo].[T0160_HRMS_Training_Questionnaire_Response] (
    [Tran_Response_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]           NUMERIC (18)    NULL,
    [Training_Apr_ID]  NUMERIC (18)    NULL,
    [Training_id]      NUMERIC (18)    NULL,
    [Emp_id]           NUMERIC (18)    NULL,
    [Tran_Question_Id] NUMERIC (18)    NULL,
    [Answer]           VARCHAR (800)   NULL,
    [CreateDate]       DATETIME        NULL,
    [Marks_obtained]   NUMERIC (18, 2) NULL,
    [Tran_Id]          NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0160_HRMS_Training_Questionnaire_Response] PRIMARY KEY CLUSTERED ([Tran_Response_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0040_Hrms_Training_master] FOREIGN KEY ([Training_id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0080_EMP_MASTER] FOREIGN KEY ([Emp_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0120_HRMS_TRAINING_APPROVAL] FOREIGN KEY ([Training_Apr_ID]) REFERENCES [dbo].[T0120_HRMS_TRAINING_APPROVAL] ([Training_Apr_ID]),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0150_HRMS_TRAINING_Questionnaire] FOREIGN KEY ([Tran_Question_Id]) REFERENCES [dbo].[T0150_HRMS_TRAINING_Questionnaire] ([Training_Que_ID]),
    CONSTRAINT [FK_T0160_HRMS_Training_Questionnaire_Response_T0152_Hrms_Training_Quest_Final] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0152_Hrms_Training_Quest_Final] ([Tran_Id])
);

