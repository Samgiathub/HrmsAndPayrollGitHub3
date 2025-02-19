CREATE TABLE [dbo].[T0050_Production_Details_Import] (
    [Tran_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NULL,
    [Employee_ID]       NUMERIC (18)    NULL,
    [Production_Month]  NUMERIC (2)     NULL,
    [Production_Year]   NUMERIC (4)     NULL,
    [Production_PCS]    NUMERIC (18, 2) NULL,
    [Production_Amount] NUMERIC (18, 2) NULL,
    [Incentive_Amount]  NUMERIC (18, 2) NULL,
    [Card_Amount]       NUMERIC (18, 2) NULL,
    [Gross_Amount]      NUMERIC (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

