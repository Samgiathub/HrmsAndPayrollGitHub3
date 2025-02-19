CREATE TABLE [dbo].[T0040_Salary_Cycle_Master] (
    [Tran_Id]        NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_id]         NUMERIC (18)  NOT NULL,
    [Name]           NVARCHAR (50) NOT NULL,
    [Salary_st_date] DATETIME      NOT NULL,
    CONSTRAINT [PK_T0040_Salary_Cycle_Master] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Salary_Cycle_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

