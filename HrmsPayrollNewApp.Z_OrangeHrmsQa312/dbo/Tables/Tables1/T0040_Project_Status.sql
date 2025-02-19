CREATE TABLE [dbo].[T0040_Project_Status] (
    [Project_Status_ID] NUMERIC (18)  NOT NULL,
    [Project_Status]    VARCHAR (50)  NULL,
    [Remarks]           VARCHAR (MAX) NULL,
    [Cmp_ID]            NUMERIC (18)  NULL,
    [Created_By]        NUMERIC (18)  NULL,
    [Created_Date]      DATETIME      NULL,
    [Modify_By]         NUMERIC (18)  NULL,
    [Modify_Date]       DATETIME      NULL,
    [Color]             NVARCHAR (50) NULL,
    [Status_Type]       NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_Project_Status] PRIMARY KEY CLUSTERED ([Project_Status_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Project_Status_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Project_Status_T0011_LOGIN] FOREIGN KEY ([Created_By]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);

