CREATE TABLE [dbo].[T0110_Claim_BookDetails] (
    [cb_MainId]          INT           IDENTITY (1, 1) NOT NULL,
    [cb_AppId]           INT           NULL,
    [cb_ClaimId]         INT           NULL,
    [cb_EmpId]           INT           NULL,
    [cb_BookName]        VARCHAR (100) NULL,
    [cb_Subject]         VARCHAR (50)  NULL,
    [cb_ActualPrice]     FLOAT (53)    NULL,
    [cb_DiscountedPrice] FLOAT (53)    NULL,
    [cb_Amount]          FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_BookDetails] PRIMARY KEY CLUSTERED ([cb_MainId] ASC) WITH (FILLFACTOR = 95)
);

