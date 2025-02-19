CREATE TABLE [dbo].[tbl_Letters] (
    [lt_Id]           INT           IDENTITY (1, 1) NOT NULL,
    [lt_LetterType]   INT           NULL,
    [lt_LetterFormat] INT           NULL,
    [lt_Description]  VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_Letters] PRIMARY KEY CLUSTERED ([lt_Id] ASC) WITH (FILLFACTOR = 95)
);

