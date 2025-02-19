CREATE TABLE [dbo].[T0100_GRATUITY] (
    [Gr_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [Emp_Id]         NUMERIC (18)   NOT NULL,
    [From_Date]      DATETIME       NOT NULL,
    [To_Date]        DATETIME       NOT NULL,
    [Paid_Date]      DATETIME       NOT NULL,
    [Gr_Calc_Amount] NUMERIC (18)   NOT NULL,
    [Gr_Days]        NUMERIC (5, 1) NOT NULL,
    [Gr_Percentage]  NUMERIC (5, 2) NOT NULL,
    [Gr_Amount]      NUMERIC (10)   NOT NULL,
    [Gr_Calc_Type]   VARCHAR (10)   NOT NULL,
    [Gr_FNF]         TINYINT        NOT NULL,
    [Gr_Years]       NUMERIC (5, 1) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_GRATUITY] PRIMARY KEY CLUSTERED ([Gr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_GRATUITY_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_GRATUITY_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

