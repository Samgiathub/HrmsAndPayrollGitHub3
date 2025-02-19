CREATE TABLE [dbo].[T0095_IT_Emp_Tax_Regime] (
    [Tran_ID]        NUMERIC (18) NOT NULL,
    [Emp_ID]         NUMERIC (18) NOT NULL,
    [Financial_Year] VARCHAR (10) NOT NULL,
    [Regime]         VARCHAR (15) NOT NULL,
    [User_ID]        NUMERIC (18) NULL,
    [System_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0095_IT_Emp_Tax_Regime] PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK_T0095_IT_Emp_Tax_Regime_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

