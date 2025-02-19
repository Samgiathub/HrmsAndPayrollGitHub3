CREATE TABLE [dbo].[LogInLogDetails] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]         INT            NULL,
    [User_Id]        NVARCHAR (100) NULL,
    [IPAddress]      NVARCHAR (100) NULL,
    [LogInDateTime]  DATETIME       NULL,
    [LogOutDateTime] DATETIME       NULL,
    [Islogged]       BIT            NULL,
    CONSTRAINT [PK_LogInLogDetails] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

