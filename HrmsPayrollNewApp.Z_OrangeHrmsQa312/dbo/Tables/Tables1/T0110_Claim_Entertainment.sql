CREATE TABLE [dbo].[T0110_Claim_Entertainment] (
    [ec_Id]              INT           IDENTITY (1, 1) NOT NULL,
    [ec_ClaimAppId]      INT           NULL,
    [ec_ClaimId]         INT           NULL,
    [ec_Date]            SMALLDATETIME NULL,
    [ec_NoOfEntertained] VARCHAR (MAX) NULL,
    [ec_Amount]          FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Entertainment] PRIMARY KEY CLUSTERED ([ec_Id] ASC) WITH (FILLFACTOR = 95)
);

