CREATE TABLE [dbo].[T0080_Cost_Center_Detail] (
    [Tran_ID]         NUMERIC (18) NOT NULL,
    [Cmp_ID]          NUMERIC (18) NOT NULL,
    [Cost_Cat_ID]     NUMERIC (18) NOT NULL,
    [Cost_Center_ID]  NUMERIC (18) NOT NULL,
    [Sal_Tran_Exp_ID] NUMERIC (18) NOT NULL,
    [Amount]          NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0080_Cost_Center_Detail] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0080_Cost_Center_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0080_Cost_Center_Detail_T0040_Cost_Category] FOREIGN KEY ([Cost_Cat_ID]) REFERENCES [dbo].[T0040_Cost_Category] ([Tally_Cat_ID]),
    CONSTRAINT [FK_T0080_Cost_Center_Detail_T0040_Cost_Center] FOREIGN KEY ([Cost_Center_ID]) REFERENCES [dbo].[T0040_Cost_Center] ([Tally_Center_ID])
);

