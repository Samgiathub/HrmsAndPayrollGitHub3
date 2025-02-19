CREATE TABLE [dbo].[T0510_Sales_Compliance_Details] (
    [Tran_ID]          NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NULL,
    [Comp_ID]          NUMERIC (18)    NULL,
    [Client_Code]      VARCHAR (100)   NULL,
    [Emp_Code]         VARCHAR (100)   NULL,
    [Reg_Date]         DATETIME        NULL,
    [Comp_Description] VARCHAR (250)   NULL,
    [Comp_Amount]      NUMERIC (18, 2) NULL,
    [Resolved_Date]    DATETIME        NULL,
    [Resolved_Desc]    VARCHAR (500)   NULL,
    [UserID]           NUMERIC (18)    NULL,
    [Modify_Date]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

