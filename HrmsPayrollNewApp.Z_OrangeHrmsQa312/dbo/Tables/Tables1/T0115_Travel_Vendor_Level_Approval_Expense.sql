CREATE TABLE [dbo].[T0115_Travel_Vendor_Level_Approval_Expense] (
    [Tran_ID]              NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NOT NULL,
    [Emp_ID]               NUMERIC (18)    NOT NULL,
    [Travel_Approval_ID]   NUMERIC (18)    NOT NULL,
    [Travel_Settlement_ID] NUMERIC (18)    NOT NULL,
    [Project_ID]           NUMERIC (18)    NOT NULL,
    [Vendor_ID]            NUMERIC (18)    NOT NULL,
    [Order_Type_ID]        NUMERIC (18)    NOT NULL,
    [Tax_Component_ID]     NUMERIC (18)    NULL,
    [Item_Description]     VARCHAR (MAX)   NULL,
    [Quantity]             NUMERIC (18, 2) NOT NULL,
    [Rate]                 NUMERIC (18, 2) NOT NULL,
    [Amount]               NUMERIC (18, 2) NOT NULL,
    [Approved_Amount]      NUMERIC (18, 2) NOT NULL,
    [Tax_Per]              NUMERIC (18, 2) NOT NULL,
    [Self_Pay]             TINYINT         NOT NULL,
    [Remarks]              VARCHAR (MAX)   NULL,
    [Rpt_Level]            NUMERIC (18)    NOT NULL,
    [Manager_Emp_ID]       NUMERIC (18)    NOT NULL,
    [Modify_Date]          DATETIME        NOT NULL,
    CONSTRAINT [PK_T0115_Travel_Vendor_Level_Approval_Expense] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

