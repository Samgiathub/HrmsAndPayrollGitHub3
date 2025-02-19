CREATE TABLE [dbo].[T0110_Claim_Insurance_Details] (
    [ci_Id]         INT           IDENTITY (1, 1) NOT NULL,
    [ci_ClaimAppId] INT           NULL,
    [ci_EmpId]      INT           NULL,
    [ci_ClaimId]    INT           NULL,
    [ci_VehicleNo]  VARCHAR (200) NULL,
    [ci_BillDate]   SMALLDATETIME NULL,
    [ci_PaidAmount] FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Insurance_Details] PRIMARY KEY CLUSTERED ([ci_Id] ASC) WITH (FILLFACTOR = 95)
);

