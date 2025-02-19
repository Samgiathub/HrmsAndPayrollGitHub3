CREATE TABLE [dbo].[T0041_Claim_Maxlimit_Design] (
    [Tran_ID]            NUMERIC (18)    NOT NULL,
    [Claim_ID]           NUMERIC (18)    NOT NULL,
    [Desig_ID]           NUMERIC (18)    NULL,
    [Max_Unit]           NUMERIC (18)    NULL,
    [Max_Limit_Km]       NUMERIC (18, 2) CONSTRAINT [DF_T0041_Claim_Maxlimit_Design_Max_Limit_Km] DEFAULT ((0)) NOT NULL,
    [Rate_Per_Km]        NUMERIC (18, 2) CONSTRAINT [DF_T0041_Claim_Maxlimit_Design_Rate_Per_Km] DEFAULT ((0)) NOT NULL,
    [Grade_ID]           NUMERIC (18)    NULL,
    [Branch_ID]          NUMERIC (18)    NULL,
    [UnitId]             NUMERIC (18)    NULL,
    [After_Joining_Days] INT             NULL,
    [Min_KM]             FLOAT (53)      NULL,
    CONSTRAINT [PK_T0041_Claim_Maxlimit_Design] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0041_Claim_Maxlimit_Design_T0040_CLAIM_MASTER] FOREIGN KEY ([Claim_ID]) REFERENCES [dbo].[T0040_CLAIM_MASTER] ([Claim_ID]),
    CONSTRAINT [FK_T0041_Claim_Maxlimit_Design_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_ID]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID])
);

