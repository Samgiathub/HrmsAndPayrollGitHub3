CREATE TABLE [dbo].[T0220_TDS_CHALLAN] (
    [Challan_Id]      NUMERIC (18)    NOT NULL,
    [cmp_id]          NUMERIC (18)    NOT NULL,
    [Month]           NUMERIC (18)    NOT NULL,
    [Year]            NUMERIC (18)    NOT NULL,
    [Payment_Date]    DATETIME        NULL,
    [Bank_ID]         NUMERIC (18)    NULL,
    [Bank_Name]       VARCHAR (100)   NULL,
    [Bank_BSR_Code]   VARCHAR (50)    NULL,
    [Paid_By]         VARCHAR (50)    NULL,
    [Cheque_No]       VARCHAR (50)    NULL,
    [CIN_No]          VARCHAR (50)    NULL,
    [Cheque_Date]     DATETIME        NULL,
    [Tax_Amount]      NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Tax_Amount] DEFAULT ((0)) NOT NULL,
    [ED_Cess]         NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_ED_Cess] DEFAULT ((0)) NOT NULL,
    [Interest_Amount] NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Interest_Amount] DEFAULT ((0)) NOT NULL,
    [Penalty_Amount]  NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Penalty_Amount] DEFAULT ((0)) NOT NULL,
    [Other_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Other_Amount] DEFAULT ((0)) NOT NULL,
    [Total_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Total_Amount] DEFAULT ((0)) NOT NULL,
    [Challan_type]    BIGINT          CONSTRAINT [DF_T0220_TDS_CHALLAN_Challan_type] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TDS_Challan] PRIMARY KEY CLUSTERED ([Challan_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TDS_Challan_Company_Master] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

