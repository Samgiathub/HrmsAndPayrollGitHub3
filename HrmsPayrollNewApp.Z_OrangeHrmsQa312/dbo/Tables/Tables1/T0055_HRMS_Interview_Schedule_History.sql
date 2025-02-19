CREATE TABLE [dbo].[T0055_HRMS_Interview_Schedule_History] (
    [Interview_Schedule_History_Id] NUMERIC (18) NOT NULL,
    [Interview_Process_Detail_Id]   NUMERIC (18) NULL,
    [Cmp_Id]                        NUMERIC (18) NOT NULL,
    [Rec_Post_Id]                   NUMERIC (18) NOT NULL,
    [Resume_Id]                     NUMERIC (18) NOT NULL,
    [S_Emp_Id]                      NUMERIC (18) NULL,
    [S_Emp_Id2]                     NUMERIC (18) NULL,
    [S_Emp_Id3]                     NUMERIC (18) NULL,
    [S_Emp_Id4]                     NUMERIC (18) NULL,
    [From_Date]                     DATETIME     NULL,
    [To_Date]                       DATETIME     NULL,
    [From_Time]                     VARCHAR (50) NULL,
    [To_Time]                       VARCHAR (50) NULL,
    [BypassInterview]               TINYINT      NULL,
    [System_Date]                   DATETIME     NOT NULL,
    CONSTRAINT [PK_T0055_HRMS_Interview_Schedule_History] PRIMARY KEY CLUSTERED ([Interview_Schedule_History_Id] ASC),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_History_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_History_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_Id]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_History_T0055_Interview_Process_Detail] FOREIGN KEY ([Interview_Process_Detail_Id]) REFERENCES [dbo].[T0055_Interview_Process_Detail] ([Interview_Process_detail_ID]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_History_T0055_Resume_Master] FOREIGN KEY ([Resume_Id]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id]),
    CONSTRAINT [FK_T0055_HRMS_Interview_Schedule_History_T0080_EMP_MASTER] FOREIGN KEY ([S_Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

