CREATE TABLE [dbo].[T0110_Claim_EducationDetails] (
    [ced_Id]                INT           IDENTITY (1, 1) NOT NULL,
    [ced_ClaimAppId]        INT           NULL,
    [ced_EmpId]             INT           NULL,
    [ced_RowId]             INT           NULL,
    [ced_Name]              VARCHAR (100) NULL,
    [ced_RelationId]        INT           NULL,
    [ced_RelationName]      VARCHAR (100) NULL,
    [ced_SchoolCollegeName] VARCHAR (300) NULL,
    [ced_ClassName]         VARCHAR (300) NULL,
    [ced_EducatinLevel]     VARCHAR (100) NULL,
    [ced_RequestedAmount]   FLOAT (53)    NULL,
    [ced_QuarterId]         INT           NULL,
    [ced_Quarter]           VARCHAR (50)  NULL,
    CONSTRAINT [PK_T0110_Claim_EducationDetails] PRIMARY KEY CLUSTERED ([ced_Id] ASC) WITH (FILLFACTOR = 95)
);

