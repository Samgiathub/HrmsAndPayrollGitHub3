CREATE TABLE [dbo].[T0060_Hrms_Interview_Feedback_detail] (
    [Feedback_detail_id]    NUMERIC (18)    NOT NULL,
    [Interview_Schedule_Id] NUMERIC (18)    NULL,
    [Login_id]              NUMERIC (18)    NULL,
    [Emp_id]                NUMERIC (18)    NULL,
    [Cmp_id]                NUMERIC (18)    NOT NULL,
    [Rec_Post_Id]           NUMERIC (18)    NULL,
    [Process_Q_ID]          NUMERIC (18)    NOT NULL,
    [Description]           VARCHAR (1000)  NULL,
    [Rating]                NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0060_Hrms_Interview_Feedback_detail] PRIMARY KEY CLUSTERED ([Feedback_detail_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0060_Hrms_Interview_Feedback_detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_Hrms_Interview_Feedback_detail_T0011_LOGIN] FOREIGN KEY ([Login_id]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0060_Hrms_Interview_Feedback_detail_T0045_HRMS_R_PROCESS_TEMPLATE] FOREIGN KEY ([Process_Q_ID]) REFERENCES [dbo].[T0045_HRMS_R_PROCESS_TEMPLATE] ([Process_Q_ID]),
    CONSTRAINT [FK_T0060_Hrms_Interview_Feedback_detail_T0055_HRMS_Interview_Schedule] FOREIGN KEY ([Interview_Schedule_Id]) REFERENCES [dbo].[T0055_HRMS_Interview_Schedule] ([Interview_Schedule_Id])
);

