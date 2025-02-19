CREATE TABLE [dbo].[T0110_Claim_Approval_Entertainment] (
    [eca_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [eca_ClaimAppId]      INT           NULL,
    [eca_ClaimId]         INT           NULL,
    [eca_Date]            SMALLDATETIME NULL,
    [eca_NoOfEntertained] VARCHAR (MAX) NULL,
    [eca_Amount]          FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Approval_Entertainment] PRIMARY KEY CLUSTERED ([eca_Id] ASC) WITH (FILLFACTOR = 95)
);

