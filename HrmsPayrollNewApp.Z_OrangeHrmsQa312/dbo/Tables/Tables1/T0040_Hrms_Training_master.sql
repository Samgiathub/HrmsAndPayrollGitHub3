CREATE TABLE [dbo].[T0040_Hrms_Training_master] (
    [Training_id]          NUMERIC (18)    NOT NULL,
    [Training_name]        VARCHAR (200)   NULL,
    [Training_description] VARCHAR (500)   NULL,
    [Cmp_Id]               NUMERIC (18)    NULL,
    [Training_Category_Id] NUMERIC (18)    NULL,
    [Training_MCP]         NUMERIC (18, 2) NULL,
    [Training_Cordinator]  VARCHAR (250)   DEFAULT ('') NOT NULL,
    [Training_Director]    VARCHAR (250)   DEFAULT ('') NOT NULL,
    [Training_Type]        NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0040_Hrms_Training_master] PRIMARY KEY CLUSTERED ([Training_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Hrms_Training_master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

