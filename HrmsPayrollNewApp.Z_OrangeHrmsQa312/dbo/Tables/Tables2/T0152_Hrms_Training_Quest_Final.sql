CREATE TABLE [dbo].[T0152_Hrms_Training_Quest_Final] (
    [Tran_Id]         NUMERIC (18)    NOT NULL,
    [Cmp_Id]          NUMERIC (18)    NOT NULL,
    [Training_Que_ID] NUMERIC (18)    NULL,
    [Training_Apr_Id] NUMERIC (18)    NULL,
    [Training_Id]     NUMERIC (18)    NULL,
    [Marks]           NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0152_Hrms_Training_Quest_Final] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0152_Hrms_Training_Quest_Final_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0152_Hrms_Training_Quest_Final_T0040_Hrms_Training_master] FOREIGN KEY ([Training_Id]) REFERENCES [dbo].[T0040_Hrms_Training_master] ([Training_id]),
    CONSTRAINT [FK_T0152_Hrms_Training_Quest_Final_T0120_HRMS_TRAINING_APPROVAL] FOREIGN KEY ([Training_Apr_Id]) REFERENCES [dbo].[T0120_HRMS_TRAINING_APPROVAL] ([Training_Apr_ID]),
    CONSTRAINT [FK_T0152_Hrms_Training_Quest_Final_T0150_HRMS_TRAINING_Questionnaire] FOREIGN KEY ([Training_Que_ID]) REFERENCES [dbo].[T0150_HRMS_TRAINING_Questionnaire] ([Training_Que_ID])
);

