CREATE TABLE [dbo].[T0080_Loan_HycScheme] (
    [Srno]       NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]     INT          NULL,
    [RptLevel]   NUMERIC (18) NULL,
    [SchemeIId]  NUMERIC (18) NULL,
    [DynHierId]  NUMERIC (18) NULL,
    [LoanTypeId] VARCHAR (50) NULL,
    [AppEmp]     NUMERIC (18) NULL,
    [AppId]      NUMERIC (18) NULL,
    [RptEmp]     NUMERIC (18) NULL,
    [CreateDate] DATETIME     NULL,
    CONSTRAINT [PK_T0080_Loan_HycScheme] PRIMARY KEY CLUSTERED ([Srno] ASC) WITH (FILLFACTOR = 95)
);

