CREATE TABLE [dbo].[T0040_Claim_Group_Master] (
    [Claim_Group_Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]           INT           NULL,
    [Claim_Group_Name] VARCHAR (50)  NULL,
    [System_Date]      SMALLDATETIME NULL,
    CONSTRAINT [PK_T0040_Claim_Group_Master] PRIMARY KEY CLUSTERED ([Claim_Group_Id] ASC) WITH (FILLFACTOR = 95)
);

