CREATE TABLE [dbo].[Internal_FK_Definition_Storage] (
    [ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [FK_Name]                   VARCHAR (250) NOT NULL,
    [FK_CreationStatement]      VARCHAR (MAX) NOT NULL,
    [FK_DestructionStatement]   VARCHAR (MAX) NOT NULL,
    [Table_TruncationStatement] VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

