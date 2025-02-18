﻿CREATE TABLE [dbo].[T0220_PF_CHALLAN] (
    [Pf_Challan_ID]                     NUMERIC (18)  NOT NULL,
    [Cmp_ID]                            NUMERIC (18)  NOT NULL,
    [Branch_ID]                         NUMERIC (18)  NULL,
    [Bank_ID]                           NUMERIC (18)  NOT NULL,
    [Month]                             NUMERIC (18)  NOT NULL,
    [Year]                              NUMERIC (18)  NOT NULL,
    [Payment_Date]                      DATETIME      NOT NULL,
    [E_Code]                            VARCHAR (20)  NOT NULL,
    [Acc_Gr_No]                         VARCHAR (5)   NOT NULL,
    [Payment_Mode]                      VARCHAR (20)  NOT NULL,
    [Cheque_No]                         VARCHAR (10)  NOT NULL,
    [Total_SubScriber]                  NUMERIC (18)  CONSTRAINT [DF_Table1_TOTAL_SUBSCRIBER] DEFAULT ((0)) NOT NULL,
    [Total_Wages_Due]                   NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_Wages_Due] DEFAULT ((0)) NOT NULL,
    [Total_Challan_Amount]              NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_Challan_Amount] DEFAULT ((0)) NULL,
    [Total_Family_Pension_Subscriber]   NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_Family_Pension_Subscriber] DEFAULT ((0)) NULL,
    [Total_Family_Pension_Wages_Amount] NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_Family_Pension_Wages_Amount] DEFAULT ((0)) NULL,
    [Total_EDLI_Subscriber]             NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_EDLI_Subscriber] DEFAULT ((0)) NULL,
    [Total_EDLI_Wages_Amount]           NUMERIC (18)  CONSTRAINT [DF_T0220_PF_CHALLAN_Total_EDLI_Wages_Amount] DEFAULT ((0)) NULL,
    [Branch_ID_Multi]                   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0220_PF_CHALLAN] PRIMARY KEY CLUSTERED ([Pf_Challan_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0220_PF_CHALLAN_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0220_PF_CHALLAN_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

