CREATE TABLE [dbo].[T0090_Emp_Evaluation_Detail] (
    [Evalution_ID]   NUMERIC (18)   NOT NULL,
    [Emp_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [Conducted_Date] DATETIME       NOT NULL,
    [Grade]          NUMERIC (18)   NOT NULL,
    [Comments]       VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_T0090_Emp_Evaluation_Detail] PRIMARY KEY CLUSTERED ([Evalution_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Emp_Evaluation_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Emp_Evaluation_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

