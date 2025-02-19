CREATE TABLE [dbo].[T0041_Claim_Maxlimit_Age] (
    [Age_Id]     INT        IDENTITY (1, 1) NOT NULL,
    [Claim_Id]   INT        NULL,
    [Age_Min]    FLOAT (53) NULL,
    [Age_Max]    FLOAT (53) NULL,
    [Age_Amount] FLOAT (53) NULL,
    [GradeId]    INT        NULL,
    CONSTRAINT [PK_T0041_Claim_Maxlimit_Age] PRIMARY KEY CLUSTERED ([Age_Id] ASC)
);

