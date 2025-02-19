CREATE TABLE [dbo].[T0055_Interview_Process_Question_Detail] (
    [Rec_Posted_Question_Process_Id] NUMERIC (18) NOT NULL,
    [Cmp_ID]                         NUMERIC (18) NOT NULL,
    [Process_Id]                     NUMERIC (18) NOT NULL,
    [Process_Q_ID]                   NUMERIC (18) NOT NULL,
    [Rec_Post_Id]                    NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0055_Interview_Process_Question_Detail] PRIMARY KEY CLUSTERED ([Rec_Posted_Question_Process_Id] ASC),
    CONSTRAINT [FK_T0055_Interview_Process_Question_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_Interview_Process_Question_Detail_T0040_HRMS_R_PROCESS_MASTER] FOREIGN KEY ([Process_Id]) REFERENCES [dbo].[T0040_HRMS_R_PROCESS_MASTER] ([Process_ID]),
    CONSTRAINT [FK_T0055_Interview_Process_Question_Detail_T0045_HRMS_R_PROCESS_TEMPLATE] FOREIGN KEY ([Process_Q_ID]) REFERENCES [dbo].[T0045_HRMS_R_PROCESS_TEMPLATE] ([Process_Q_ID]),
    CONSTRAINT [FK_T0055_Interview_Process_Question_Detail_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_Id]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id])
);

