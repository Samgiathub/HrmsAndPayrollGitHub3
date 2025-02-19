CREATE TABLE [dbo].[T0210_Final_Retaining_Payment] (
    [Tran_Id]       NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [For_Date]      DATETIME        CONSTRAINT [DF_T0210_For_Date] DEFAULT (getdate()) NOT NULL,
    [Cmp_Id]        NUMERIC (18)    NOT NULL,
    [Emp_Id]        NUMERIC (18)    CONSTRAINT [DF_T0210_Final_Retaining_Payment_Emp_Id] DEFAULT ((0)) NOT NULL,
    [Hours]         NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Hours] DEFAULT ((0)) NOT NULL,
    [Retain_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Amount] DEFAULT ((0)) NOT NULL,
    [Esic]          NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Esic] DEFAULT ((0)) NOT NULL,
    [Net_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Net_Amount] DEFAULT ((0)) NOT NULL,
    [Ad_Id]         NUMERIC (18)    CONSTRAINT [DF_T0210_Final_Retaining_Payment_Ad_Id] DEFAULT ((0)) NOT NULL,
    [Modify_Date]   DATETIME        CONSTRAINT [DF_T0210_Final_Retaining_Payment_Modify_Date] DEFAULT (getdate()) NOT NULL,
    [Comp_Esic]     NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Comp_Esic] DEFAULT ((0)) NOT NULL,
    [TDS]           NUMERIC (18, 2) CONSTRAINT [DF_T0210_Final_Retaining_Payment_TDS] DEFAULT ((0)) NOT NULL,
    [PF]            NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Working_Days]  NUMERIC (18, 4) CONSTRAINT [DF_T0210_Final_Retaining_Payment_Working_Days] DEFAULT ((0)) NOT NULL,
    [Calculate_on]  NUMERIC (18)    CONSTRAINT [DF_T0210_Final_Retaining_Payment_Calculate_on] DEFAULT ((0)) NOT NULL,
    [Ret_Tran_id]   INT             DEFAULT ((0)) NULL,
    [VPF]           NUMERIC (18, 2) NULL,
    [CPF]           NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0210_Final_Retaining_Payment] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

