CREATE TABLE [dbo].[T0110_Claim_FamilyDetails] (
    [Claim_MainId]           INT           IDENTITY (1, 1) NOT NULL,
    [Claim_FamilyMemberId]   INT           NULL,
    [Claim_AppId]            INT           NULL,
    [ClaimId]                INT           NULL,
    [Claim_EmpId]            INT           NULL,
    [Claim_FamilyMemberName] VARCHAR (100) NULL,
    [Claim_FamilyRelation]   VARCHAR (50)  NULL,
    [Claim_Age]              FLOAT (53)    NULL,
    [Claim_Limit]            FLOAT (53)    NULL,
    [Claim_Amount]           FLOAT (53)    NULL,
    [cf_BirthDate]           SMALLDATETIME NULL,
    [cf_BillNumber]          VARCHAR (100) NULL,
    [cf_BillDate]            SMALLDATETIME NULL,
    [cf_BillAmount]          FLOAT (53)    NULL,
    CONSTRAINT [PK_T0110_Claim_FamilyDetails] PRIMARY KEY CLUSTERED ([Claim_MainId] ASC) WITH (FILLFACTOR = 95)
);

