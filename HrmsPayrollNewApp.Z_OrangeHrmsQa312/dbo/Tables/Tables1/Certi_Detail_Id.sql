CREATE TABLE [dbo].[Certi_Detail_Id] (
    [Certi_Detail_Id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Certi_Id]                  NUMERIC (18)    NULL,
    [Cmp_Id]                    NUMERIC (18)    NULL,
    [Emp_Id]                    NUMERIC (18)    NULL,
    [Skill_Level]               NVARCHAR (50)   NULL,
    [Exp_Years]                 NUMERIC (16, 2) NULL,
    [Is_TrainingAttended]       INT             NULL,
    [Training_Certi_Attachment] NVARCHAR (100)  NULL,
    [Is_ExamAttended]           INT             NULL,
    [Exam_Certi_Attachment]     NVARCHAR (100)  NULL,
    [Descriptions]              NVARCHAR (MAX)  NULL,
    [Created_By]                NUMERIC (18)    NULL,
    [Created_Date]              DATETIME        NULL,
    CONSTRAINT [PK_T0500_Certificateskill_Detail] PRIMARY KEY CLUSTERED ([Certi_Detail_Id] ASC) WITH (FILLFACTOR = 95)
);

