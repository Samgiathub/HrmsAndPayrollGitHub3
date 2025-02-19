CREATE TABLE [dbo].[T0035_CONTRACTOR_DETAIL_MASTER] (
    [Contr_Det_ID]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Branch_ID]            NUMERIC (18)  NULL,
    [Contr_PersonName]     VARCHAR (100) NULL,
    [Contr_Email]          VARCHAR (50)  NULL,
    [Contr_MobileNo]       VARCHAR (30)  NULL,
    [Contr_Aadhaar]        VARCHAR (30)  NULL,
    [Contr_GSTNumber]      VARCHAR (30)  NULL,
    [Nature_Of_Work]       VARCHAR (500) NULL,
    [No_Of_LabourEmployed] NUMERIC (18)  NULL,
    [Date_Of_Commencement] DATETIME      NULL,
    [Date_Of_Termination]  DATETIME      NULL,
    [Vendor_Code]          VARCHAR (20)  NULL,
    [LICENCE_DOC]          VARCHAR (50)  NULL,
    CONSTRAINT [PK_Contractual_Master] PRIMARY KEY CLUSTERED ([Contr_Det_ID] ASC),
    CONSTRAINT [FK_T0035_CONTRACTOR_DETAIL_MASTER_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

