CREATE TABLE [dbo].[T0500_Ess_Certificateskill_Details] (
    [Certi_Detail_Id]           NUMERIC (18)   NOT NULL,
    [Certi_Id]                  NUMERIC (18)   NULL,
    [Cmp_Id]                    NUMERIC (18)   NULL,
    [Emp_Id]                    NUMERIC (18)   NULL,
    [Skill_Level]               NVARCHAR (50)  NULL,
    [Exp_Years]                 NUMERIC (18)   NULL,
    [Is_TrainingAttended]       NUMERIC (18)   NULL,
    [Training_Certi_Attachment] NVARCHAR (100) NULL,
    [Is_ExamAttended]           NUMERIC (18)   NULL,
    [Exam_Certi_Attachment]     NVARCHAR (100) NULL,
    [Descriptions]              NVARCHAR (MAX) NULL,
    [Created_By]                NUMERIC (18)   NULL,
    [Created_Date]              DATETIME       NULL,
    CONSTRAINT [PK_T0500_Ess_Certificateskill_Details] PRIMARY KEY CLUSTERED ([Certi_Detail_Id] ASC) WITH (FILLFACTOR = 95)
);

