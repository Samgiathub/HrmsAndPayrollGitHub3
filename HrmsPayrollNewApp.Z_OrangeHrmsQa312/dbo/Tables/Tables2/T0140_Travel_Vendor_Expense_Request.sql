CREATE TABLE [dbo].[T0140_Travel_Vendor_Expense_Request] (
    [Tran_ID]            NUMERIC (18)    NOT NULL,
    [Travel_Approval_ID] NUMERIC (18)    NOT NULL,
    [Project_ID]         NUMERIC (18)    NOT NULL,
    [Vendor_ID]          NUMERIC (18)    NOT NULL,
    [Description]        VARCHAR (MAX)   NULL,
    [Quantity]           NUMERIC (18, 2) NOT NULL,
    [Rate]               NUMERIC (18, 2) NOT NULL,
    [Tax_Components]     NUMERIC (18)    NULL,
    [Tax_Percentage]     NUMERIC (18)    NULL,
    [Total_Amount]       NUMERIC (18, 2) NOT NULL,
    [Remarks]            VARCHAR (MAX)   NULL,
    [Emp_ID]             NUMERIC (18)    NOT NULL,
    [Self_Pay]           TINYINT         NULL,
    [Cmp_ID]             NUMERIC (18)    NOT NULL,
    [Order_Type_ID]      NUMERIC (18)    CONSTRAINT [DF__T0140_Tra__Order__4B6E107F] DEFAULT ((0)) NOT NULL,
    [Modify_Date]        DATETIME2 (7)   CONSTRAINT [DF_T0140_Travel_Vendor_Expense_Request_Modify_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0140_Travel_Vendor_Expense_Request] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

