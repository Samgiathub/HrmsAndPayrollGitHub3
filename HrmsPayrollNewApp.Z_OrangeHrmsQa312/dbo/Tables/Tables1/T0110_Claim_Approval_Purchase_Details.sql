CREATE TABLE [dbo].[T0110_Claim_Approval_Purchase_Details] (
    [cpa_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [cpa_ClaimAppId]      INT           NULL,
    [cpa_EmpId]           INT           NULL,
    [cpa_ClaimId]         INT           NULL,
    [cpa_ItemName]        VARCHAR (200) NULL,
    [cpa_SerialNo]        VARCHAR (50)  NULL,
    [cpa_VendorName]      VARCHAR (200) NULL,
    [cpa_BillNo]          VARCHAR (50)  NULL,
    [cpa_BillDate]        SMALLDATETIME NULL,
    [cpa_BillAmount]      FLOAT (53)    NULL,
    [cpa_RequestedAmount] FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Approval_Purchase_Details] PRIMARY KEY CLUSTERED ([cpa_Id] ASC) WITH (FILLFACTOR = 95)
);

