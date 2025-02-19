CREATE TABLE [dbo].[T0230_TDS_CHALLAN_DETAIL] (
    [Tran_Id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Challan_Id]        NUMERIC (18)    NOT NULL,
    [Emp_Id]            NUMERIC (18)    NOT NULL,
    [TDS_Amount]        NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Detail_TDS_Amount] DEFAULT ((0)) NOT NULL,
    [Ed_Cess]           NUMERIC (18, 2) CONSTRAINT [DF_TDS_Challan_Detail_Ed_Cess] DEFAULT ((0)) NOT NULL,
    [Additional_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0230_TDS_CHALLAN_DETAIL_Additional_Amount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TDS_Challan_Detail] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TDS_Challan_Detail_Emp_Master] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_TDS_Challan_Detail_TDS_Challan] FOREIGN KEY ([Challan_Id]) REFERENCES [dbo].[T0220_TDS_CHALLAN] ([Challan_Id])
);

