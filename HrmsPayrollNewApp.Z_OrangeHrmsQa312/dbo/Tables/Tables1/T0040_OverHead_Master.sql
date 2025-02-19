CREATE TABLE [dbo].[T0040_OverHead_Master] (
    [Overhead_ID]    INT             NOT NULL,
    [Project_cost]   NUMERIC (18, 2) NULL,
    [OverHead_Month] VARCHAR (50)    NULL,
    [OverHead_Year]  NUMERIC (18)    NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Project_ID]     NUMERIC (18)    NULL,
    [Created_by]     NUMERIC (18)    NULL,
    [Modified_By]    NUMERIC (18)    NULL,
    [Modified_Date]  DATETIME        NULL,
    [Created_date]   DATETIME        NULL,
    [Exchange_Rate]  NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0040_OverHead_Master] PRIMARY KEY CLUSTERED ([Overhead_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_OverHead_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_OverHead_Master_T0040_TS_Project_Master] FOREIGN KEY ([Project_ID]) REFERENCES [dbo].[T0040_TS_Project_Master] ([Project_ID])
);

