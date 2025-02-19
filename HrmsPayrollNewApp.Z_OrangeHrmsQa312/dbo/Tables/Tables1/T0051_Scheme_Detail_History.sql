CREATE TABLE [dbo].[T0051_Scheme_Detail_History] (
    [Tran_ID]          NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18) NOT NULL,
    [Scheme_Detail_ID] NUMERIC (18) NOT NULL,
    [Old_App_Emp_ID]   NUMERIC (18) NULL,
    [New_App_Emp_ID]   NUMERIC (18) NULL,
    [System_date]      DATETIME     NULL,
    CONSTRAINT [PK_T0051_Scheme_Detail_History] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0051_Scheme_Detail_History_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0051_Scheme_Detail_History]
    ON [dbo].[T0051_Scheme_Detail_History]([Tran_ID] ASC) WITH (FILLFACTOR = 80);

