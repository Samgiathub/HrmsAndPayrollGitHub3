CREATE TABLE [dbo].[T0110_Claim_Approval_Insurance_Details] (
    [cia_Id]         INT           IDENTITY (1, 1) NOT NULL,
    [cia_ClaimAppId] INT           NULL,
    [cia_EmpId]      INT           NULL,
    [cia_ClaimId]    INT           NULL,
    [cia_VehicleNo]  VARCHAR (200) NULL,
    [cia_BillDate]   SMALLDATETIME NULL,
    [cia_PaidAmount] FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Approval_Insurance_Details] PRIMARY KEY CLUSTERED ([cia_Id] ASC) WITH (FILLFACTOR = 95)
);

