CREATE TABLE [dbo].[T0110_Claim_Purchase_Details] (
    [cp_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [cp_ClaimAppId]      INT           NULL,
    [cp_EmpId]           INT           NULL,
    [cp_ClaimId]         INT           NULL,
    [cp_ItemName]        VARCHAR (200) NULL,
    [cp_SerialNo]        VARCHAR (50)  NULL,
    [cp_VendorName]      VARCHAR (200) NULL,
    [cp_BillNo]          VARCHAR (50)  NULL,
    [cp_BillDate]        SMALLDATETIME NULL,
    [cp_BillAmount]      FLOAT (53)    NULL,
    [cp_RequestedAmount] FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Purchase_Details] PRIMARY KEY CLUSTERED ([cp_Id] ASC) WITH (FILLFACTOR = 95)
);

