CREATE TABLE [dbo].[T0110_Claim_Approval_BookDetails] (
    [cba_MainId]          INT           IDENTITY (1, 1) NOT NULL,
    [cba_AppId]           INT           NULL,
    [cba_ClaimId]         INT           NULL,
    [cba_EmpId]           INT           NULL,
    [cba_BookName]        VARCHAR (100) NULL,
    [cba_Subject]         VARCHAR (50)  NULL,
    [cba_ActualPrice]     FLOAT (53)    NULL,
    [cba_DiscountedPrice] FLOAT (53)    NULL,
    [cba_Amount]          FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_Approval_BookDetails] PRIMARY KEY CLUSTERED ([cba_MainId] ASC) WITH (FILLFACTOR = 95)
);

