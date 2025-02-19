CREATE TABLE [dbo].[T0210_Retaining_Payment_Detail] (
    [tran_id]            NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [cmp_id]             NUMERIC (18)    NOT NULL,
    [Emp_id]             NUMERIC (18)    NOT NULL,
    [Ad_id]              NUMERIC (18)    NOT NULL,
    [for_date]           DATETIME        NOT NULL,
    [Start_date]         DATETIME        NOT NULL,
    [End_date]           DATETIME        NOT NULL,
    [Calculation_Amount] NUMERIC (18, 2) NOT NULL,
    [Period]             NUMERIC (18, 2) NOT NULL,
    [Mode]               VARCHAR (50)    NOT NULL,
    [Amount]             NUMERIC (18, 2) NULL,
    [Net_Amount]         NUMERIC (18, 2) NULL,
    [remarks]            VARCHAR (500)   NULL,
    [Modify_Date]        DATETIME        CONSTRAINT [DF_T0210_Retaining_Payment_Detail_Modify_Date] DEFAULT (getdate()) NULL,
    [Ret_Tran_Id]        INT             NULL,
    CONSTRAINT [PK_T0210_Retaining_Payment_Detail] PRIMARY KEY CLUSTERED ([tran_id] ASC) WITH (FILLFACTOR = 95)
);

