CREATE TABLE [dbo].[T0160_HRMS_Training_Questionnaire_Response_Induction] (
    [Tran_Response_Id]        NUMERIC (18)    NOT NULL,
    [Cmp_Id]                  NUMERIC (18)    NULL,
    [Checklist_ID]            NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Training_id]             NUMERIC (18)    NULL,
    [Emp_id]                  NUMERIC (18)    NULL,
    [Tran_Question_Id]        NUMERIC (18)    NULL,
    [Answer]                  VARCHAR (800)   NULL,
    [CreateDate]              DATETIME        NULL,
    [Marks_obtained]          NUMERIC (18, 2) NULL,
    [Checklist_Fun_ID]        NUMERIC (18)    NULL,
    [Induction_Training_Type] TINYINT         DEFAULT ((0)) NOT NULL,
    [Training_attempt_count]  TINYINT         NULL,
    PRIMARY KEY CLUSTERED ([Tran_Response_Id] ASC)
);

