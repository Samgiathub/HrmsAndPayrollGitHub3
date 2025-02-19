CREATE TABLE [dbo].[T0040_late_Extra_Amount] (
    [Late_Amt_ID]  NUMERIC (18)    NOT NULL,
    [Cmp_ID]       NUMERIC (18)    NOT NULL,
    [Allowance_ID] NUMERIC (18)    NOT NULL,
    [From_Days]    NUMERIC (18, 2) NOT NULL,
    [To_days]      NUMERIC (18, 2) NOT NULL,
    [Calculate_On] VARCHAR (50)    NOT NULL,
    [Late_Mode]    VARCHAR (50)    NOT NULL,
    [Limit]        NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_T0040_late_Extra_Amount] PRIMARY KEY CLUSTERED ([Late_Amt_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_late_Extra_Amount_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

