CREATE TABLE [dbo].[T0040_24Q_COLUMN_SETTINGS] (
    [Tran_Id]        INT           NOT NULL,
    [IT_24Q_Id]      INT           NOT NULL,
    [Effective_Date] DATETIME      NOT NULL,
    [Sort_Id]        INT           NOT NULL,
    [Column_No]      VARCHAR (32)  NOT NULL,
    [Column_Name]    VARCHAR (512) NOT NULL,
    [Skip_Column]    BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_24Q_COLUMN_SETTINGS] PRIMARY KEY CLUSTERED ([Tran_Id] ASC)
);

