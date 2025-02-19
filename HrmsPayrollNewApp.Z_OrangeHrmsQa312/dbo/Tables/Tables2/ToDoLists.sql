CREATE TABLE [dbo].[ToDoLists] (
    [Id]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]   NVARCHAR (MAX) NOT NULL,
    [Email]  NVARCHAR (MAX) NOT NULL,
    [Phone]  NVARCHAR (MAX) NULL,
    [Reason] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.ToDoLists] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

