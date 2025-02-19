CREATE TABLE [dbo].[T0220_PT_CHALLAN] (
    [Challan_Id]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Branch_ID]         NUMERIC (18)    NULL,
    [Month]             NUMERIC (18)    NOT NULL,
    [Year]              NUMERIC (18)    NOT NULL,
    [Payment_Date]      DATETIME        NULL,
    [Bank_ID]           NUMERIC (18)    NULL,
    [Bank_Name]         VARCHAR (100)   NULL,
    [Tax_Amount]        NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Tax_Amount] DEFAULT ((0)) NOT NULL,
    [Tax_Return_Amount] NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Tax_Return_Amount] DEFAULT ((0)) NOT NULL,
    [Interest_Amount]   NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Interest_Amount] DEFAULT ((0)) NOT NULL,
    [Penalty_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Penalty_Amount] DEFAULT ((0)) NOT NULL,
    [Other_Amount]      NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Other_Amount] DEFAULT ((0)) NOT NULL,
    [Total_Amount]      NUMERIC (18, 2) CONSTRAINT [DF_PT_Challan_Total_Amount] DEFAULT ((0)) NOT NULL,
    [Emp_Count]         NUMERIC (18)    CONSTRAINT [DF_T0220_PT_CHALLAN_Emp_Count] DEFAULT ((0)) NOT NULL,
    [Branch_ID_Multi]   VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_PT_Challan] PRIMARY KEY CLUSTERED ([Challan_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PT_Challan_Company_Master] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

