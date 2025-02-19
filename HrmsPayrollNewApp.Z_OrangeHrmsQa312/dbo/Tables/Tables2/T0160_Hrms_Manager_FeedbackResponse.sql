CREATE TABLE [dbo].[T0160_Hrms_Manager_FeedbackResponse] (
    [Tran_ManagerFeedback_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                  NUMERIC (18)  NOT NULL,
    [Training_Apr_Id]         NUMERIC (18)  NOT NULL,
    [Training_Id]             NUMERIC (18)  NOT NULL,
    [Emp_Id]                  NUMERIC (18)  NOT NULL,
    [Tran_Question_Id]        NUMERIC (18)  NOT NULL,
    [Manager_Answer]          VARCHAR (800) NULL,
    [Ans_Date]                DATETIME      NOT NULL,
    [Feedback_By]             NUMERIC (18)  NOT NULL,
    CONSTRAINT [PK_T0160_Hrms_Manager_FeedbackResponse] PRIMARY KEY CLUSTERED ([Tran_ManagerFeedback_Id] ASC),
    CONSTRAINT [FK_T0160_Hrms_Manager_FeedbackResponse_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0160_Hrms_Manager_FeedbackResponse_T0040_Hrms_Training_master] FOREIGN KEY ([Training_Id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0160_Hrms_Manager_FeedbackResponse_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0160_Hrms_Manager_FeedbackResponse_T0120_HRMS_TRAINING_APPROVAL] FOREIGN KEY ([Training_Apr_Id]) REFERENCES [dbo].[T0120_HRMS_TRAINING_APPROVAL] ([Training_Apr_ID]),
    CONSTRAINT [FK_T0160_Hrms_Manager_FeedbackResponse_T0150_HRMS_TRAINING_Questionnaire] FOREIGN KEY ([Tran_Question_Id]) REFERENCES [dbo].[T0150_HRMS_TRAINING_Questionnaire] ([Training_Que_ID])
);

