CREATE TABLE [dbo].[T0040_Subsidy_Max_Limit_Design_Wise] (
    [Tran_ID]           NUMERIC (18)    NOT NULL,
    [Loan_ID]           NUMERIC (18)    CONSTRAINT [DF_T0040_Subsidy_Max_Limit_Design_Wise_Loan_ID] DEFAULT ((0)) NOT NULL,
    [Design_ID]         NUMERIC (18)    CONSTRAINT [DF_T0040_Subsidy_Max_Limit_Design_Wise_Design_ID] DEFAULT ((0)) NOT NULL,
    [Subsidy_Max_Limit] NUMERIC (18, 2) CONSTRAINT [DF_T0040_Subsidy_Max_Limit_Design_Wise_Subsidy_Max_Limit] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_Subsidy_Max_Limit_Design_Wise] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

