CREATE TABLE [dbo].[T0200_Hold_Sal_FNF] (
    [Sal_Hold_Tran_ID]   INT             NOT NULL,
    [cmp_ID]             INT             NOT NULL,
    [Sal_Tran_ID]        INT             NOT NULL,
    [Sal_Month]          NVARCHAR (50)   NOT NULL,
    [Sal_Year]           NVARCHAR (50)   NOT NULL,
    [Sal_Amount]         NUMERIC (18, 2) NOT NULL,
    [Emp_id]             NUMERIC (18)    CONSTRAINT [DF_T0200_Hold_Sal_FNF_Emp_id] DEFAULT ((0)) NOT NULL,
    [Sal_tran_id_Effect] NUMERIC (18)    CONSTRAINT [DF_T0200_Hold_Sal_FNF_Effect_Sal_Tran_Id] DEFAULT ((0)) NOT NULL
);

