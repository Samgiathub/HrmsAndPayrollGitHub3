CREATE TABLE [dbo].[T0100_EMP_GRADE_OVERTIME] (
    [OT_Tran_ID]    NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Emp_ID]        NUMERIC (18)    NOT NULL,
    [For_Date]      DATETIME        NOT NULL,
    [OT_Hours]      VARCHAR (6)     NOT NULL,
    [Grd_ID]        NUMERIC (18)    NOT NULL,
    [Amount_Credit] NUMERIC (18, 2) NULL,
    [Amount_Debit]  NUMERIC (18, 2) NULL,
    [Import_Date]   DATETIME        NULL,
    [Basic_Salary]  NUMERIC (18, 2) NULL,
    [Is_Holiday]    TINYINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_EMP_GRADE_OVERTIME] PRIMARY KEY CLUSTERED ([OT_Tran_ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_T0100_EMP_GRADE_OVERTIME]
    ON [dbo].[T0100_EMP_GRADE_OVERTIME]([For_Date] DESC, [Emp_ID] ASC);

