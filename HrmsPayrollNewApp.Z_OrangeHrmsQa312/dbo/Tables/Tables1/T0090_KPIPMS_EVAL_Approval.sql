CREATE TABLE [dbo].[T0090_KPIPMS_EVAL_Approval] (
    [Tran_Id]                NUMERIC (18)    NOT NULL,
    [KPIPMS_ID]              NUMERIC (18)    NULL,
    [Cmp_Id]                 NUMERIC (18)    NOT NULL,
    [Emp_Id]                 NUMERIC (18)    NOT NULL,
    [S_Emp_Id]               NUMERIC (18)    NULL,
    [Approval_date]          DATETIME        NULL,
    [Rpt_Level]              INT             NULL,
    [Approval_Status]        INT             NULL,
    [KPIPMS_Type]            INT             NULL,
    [KPIPMS_Name]            VARCHAR (50)    NULL,
    [KPIPMS_FinalRating]     NUMERIC (18)    NULL,
    [KPIPMS_SupEarlyComment] VARCHAR (500)   NULL,
    [Manager_Score]          NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0090_KPIPMS_EVAL_Approval] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_KPIPMS_EVAL_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_KPIPMS_EVAL_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0090_KPIPMS_EVAL_Approval_T0080_KPIPMS_EVAL] FOREIGN KEY ([KPIPMS_ID]) REFERENCES [dbo].[T0080_KPIPMS_EVAL] ([KPIPMS_ID])
);

