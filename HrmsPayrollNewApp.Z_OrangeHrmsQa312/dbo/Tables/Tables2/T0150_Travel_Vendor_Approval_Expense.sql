CREATE TABLE [dbo].[T0150_Travel_Vendor_Approval_Expense] (
    [Tran_ID]               NUMERIC (18)    NOT NULL,
    [Cmp_ID]                NUMERIC (18)    NOT NULL,
    [Emp_ID]                NUMERIC (18)    NOT NULL,
    [Travel_Aproval_ID]     NUMERIC (18)    NOT NULL,
    [Project_ID]            NUMERIC (18)    NOT NULL,
    [Vendor_ID]             NUMERIC (18)    NOT NULL,
    [Description]           VARCHAR (MAX)   NULL,
    [Travel_Settlement_ID]  NUMERIC (18)    NOT NULL,
    [Quantity]              NUMERIC (18, 2) NOT NULL,
    [Rate]                  NUMERIC (18, 2) NOT NULL,
    [Tax_Component_ID]      NUMERIC (18)    NOT NULL,
    [Tax_Per]               NUMERIC (18, 2) NOT NULL,
    [Total_Amount]          NUMERIC (18, 2) NOT NULL,
    [Total_Approved_Amount] NUMERIC (18, 2) NOT NULL,
    [Self_Pay]              TINYINT         NOT NULL,
    [Remarks]               VARCHAR (MAX)   NULL,
    [Order_Type_ID]         NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Modify_Date]           DATETIME        CONSTRAINT [DF_T0150_Travel_Vendor_Approval_Expense_Modify_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0150_Travel_Vendor_Approval_Expense] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

