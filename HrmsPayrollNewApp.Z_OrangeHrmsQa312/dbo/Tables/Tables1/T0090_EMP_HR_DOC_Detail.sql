CREATE TABLE [dbo].[T0090_EMP_HR_DOC_Detail] (
    [Emp_doc_ID]    NUMERIC (18)   NOT NULL,
    [HR_DOC_ID]     NUMERIC (18)   NULL,
    [accetpeted]    INT            NULL,
    [accepted_date] DATETIME       NULL,
    [cmp_id]        NUMERIC (18)   NULL,
    [Emp_id]        NUMERIC (18)   NULL,
    [Doc_content]   NVARCHAR (MAX) NULL,
    [Login_id]      NUMERIC (18)   NULL,
    [Type]          TINYINT        NULL,
    CONSTRAINT [PK_T0090_EMP_HR_DOC_Detail] PRIMARY KEY CLUSTERED ([Emp_doc_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_EMP_HR_DOC_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_EMP_HR_DOC_Detail_T0040_HR_DOC_MASTER] FOREIGN KEY ([HR_DOC_ID]) REFERENCES [dbo].[T0040_HR_DOC_MASTER] ([HR_DOC_ID]),
    CONSTRAINT [FK_T0090_EMP_HR_DOC_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0090_EMP_HR_DOC_Detail_accetpeted_EmpId]
    ON [dbo].[T0090_EMP_HR_DOC_Detail]([accetpeted] ASC, [Emp_id] ASC) WITH (FILLFACTOR = 80);

