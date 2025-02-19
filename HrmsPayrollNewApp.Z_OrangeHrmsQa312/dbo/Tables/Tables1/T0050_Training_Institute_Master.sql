CREATE TABLE [dbo].[T0050_Training_Institute_Master] (
    [Training_InstituteId]   NUMERIC (18)  NOT NULL,
    [Cmp_Id]                 NUMERIC (18)  NOT NULL,
    [Training_InstituteName] VARCHAR (200) NOT NULL,
    [Training_InstituteCode] VARCHAR (50)  NULL,
    [Institute_LocationCode] VARCHAR (50)  NULL,
    [Institute_Address]      VARCHAR (200) NULL,
    [Institute_City]         VARCHAR (100) NULL,
    [Institute_StateId]      NUMERIC (18)  NULL,
    [Institute_CountryId]    NUMERIC (18)  NULL,
    [Institute_PinCode]      VARCHAR (50)  NULL,
    [Institute_Telephone]    NVARCHAR (50) NULL,
    [Institute_FaxNo]        NVARCHAR (50) NULL,
    [Institute_Email]        VARCHAR (50)  NULL,
    [Institute_Website]      VARCHAR (100) NULL,
    [Institute_AffiliatedBy] VARCHAR (100) NULL,
    CONSTRAINT [PK_T0050_Training_Institute_Master] PRIMARY KEY CLUSTERED ([Training_InstituteId] ASC),
    CONSTRAINT [FK_T0050_Training_Institute_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_Training_Institute_Master_T0020_STATE_MASTER] FOREIGN KEY ([Institute_StateId]) REFERENCES [dbo].[T0020_STATE_MASTER] ([State_ID])
);

