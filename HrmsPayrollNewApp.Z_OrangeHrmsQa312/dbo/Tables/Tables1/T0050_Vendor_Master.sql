CREATE TABLE [dbo].[T0050_Vendor_Master] (
    [Vendor_Id]              NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]                 NUMERIC (18)   NOT NULL,
    [Vendor_Name]            VARCHAR (5000) NOT NULL,
    [Vendor_Address]         VARCHAR (MAX)  NULL,
    [Vendor_Contact_No]      VARCHAR (20)   NULL,
    [Vendor_Company_Website] VARCHAR (MAX)  NULL,
    [Account_Holder_Name]    VARCHAR (5000) NULL,
    [bank_Name]              VARCHAR (5000) NULL,
    [Branch_Name]            VARCHAR (5000) NULL,
    [Account_No]             VARCHAR (500)  NULL,
    [IIFC_Code]              VARCHAR (100)  NULL,
    [Remarks]                VARCHAR (MAX)  NULL,
    [modify_date]            DATETIME       CONSTRAINT [DF_T0050_Vendor_Master_modify_date] DEFAULT (getdate()) NULL,
    [Vendor_Code]            VARCHAR (100)  DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0050_Vendor_Master] PRIMARY KEY CLUSTERED ([Vendor_Id] ASC) WITH (FILLFACTOR = 80)
);

