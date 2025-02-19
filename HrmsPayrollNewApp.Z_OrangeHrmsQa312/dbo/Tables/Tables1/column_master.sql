CREATE TABLE [dbo].[column_master] (
    [Column_id]    NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Column_value] NVARCHAR (500) NOT NULL,
    [Column_name]  NVARCHAR (500) NOT NULL,
    CONSTRAINT [PK_column_master] PRIMARY KEY CLUSTERED ([Column_id] ASC)
);

