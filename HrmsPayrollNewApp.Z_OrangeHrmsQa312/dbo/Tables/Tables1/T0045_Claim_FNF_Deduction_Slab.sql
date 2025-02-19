CREATE TABLE [dbo].[T0045_Claim_FNF_Deduction_Slab] (
    [Claim_FNF_Id]   NUMERIC (18)    NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Claim_Id]       NUMERIC (18)    NOT NULL,
    [No_of_Year]     NUMERIC (18, 2) NOT NULL,
    [Dedu_In_Per]    NUMERIC (18)    NOT NULL,
    [Effective_date] DATETIME        NOT NULL,
    CONSTRAINT [PK_T0045_Claim_FNF_Deduction_Slab] PRIMARY KEY CLUSTERED ([Claim_FNF_Id] ASC)
);

