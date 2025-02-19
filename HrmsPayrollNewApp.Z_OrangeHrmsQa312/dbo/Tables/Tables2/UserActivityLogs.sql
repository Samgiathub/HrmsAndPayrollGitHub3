CREATE TABLE [dbo].[UserActivityLogs] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [CmpId]       INT            NULL,
    [Privilege]   NVARCHAR (MAX) NULL,
    [EmpId]       INT            NULL,
    [Action]      NVARCHAR (MAX) NULL,
    [CreatedDate] DATETIME       NULL,
    CONSTRAINT [PK__UserActi__3214EC0780A53825] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

