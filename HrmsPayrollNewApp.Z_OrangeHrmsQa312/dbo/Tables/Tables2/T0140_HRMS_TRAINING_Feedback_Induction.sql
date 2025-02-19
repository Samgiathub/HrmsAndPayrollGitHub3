CREATE TABLE [dbo].[T0140_HRMS_TRAINING_Feedback_Induction] (
    [Tran_Feedback_ID]        NUMERIC (18)    NOT NULL,
    [Tran_Emp_Detail_Id]      NUMERIC (18)    NOT NULL,
    [Cmp_Id]                  NUMERIC (18)    NULL,
    [Is_Attend]               INT             NULL,
    [Reason]                  NVARCHAR (500)  NULL,
    [Emp_Score]               NUMERIC (18, 2) NULL,
    [Sup_Score]               NUMERIC (18, 2) NULL,
    [Sup_Comments]            VARCHAR (500)   NULL,
    [Sup_Suggestion]          VARCHAR (500)   NULL,
    [Emp_s_Id]                NUMERIC (18)    NULL,
    [Status]                  INT             NULL,
    [Training_ID]             INT             NULL,
    [Induction_Training_Type] INT             NULL,
    [Training_attempt_count]  TINYINT         NULL,
    [Last_attempt_score]      NUMERIC (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([Tran_Feedback_ID] ASC)
);

