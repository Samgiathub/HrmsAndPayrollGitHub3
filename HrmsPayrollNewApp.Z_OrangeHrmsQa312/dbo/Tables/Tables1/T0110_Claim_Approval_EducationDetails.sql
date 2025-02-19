CREATE TABLE [dbo].[T0110_Claim_Approval_EducationDetails] (
    [caed_Id]                INT           IDENTITY (1, 1) NOT NULL,
    [caed_ClaimAppId]        INT           NULL,
    [caed_EmpId]             INT           NULL,
    [caed_RowId]             INT           NULL,
    [caed_Name]              VARCHAR (100) NULL,
    [caed_RelationId]        INT           NULL,
    [caed_RelationName]      VARCHAR (100) NULL,
    [caed_SchoolCollegeName] VARCHAR (300) NULL,
    [caed_ClassName]         VARCHAR (300) NULL,
    [caed_EducatinLevel]     VARCHAR (100) NULL,
    [caed_RequestedAmount]   FLOAT (53)    NULL,
    [caed_QuarterId]         INT           NULL,
    [caed_Quarter]           VARCHAR (50)  NULL,
    CONSTRAINT [PK_T0110_Claim_Approval_EducationDetails] PRIMARY KEY CLUSTERED ([caed_Id] ASC) WITH (FILLFACTOR = 95)
);

