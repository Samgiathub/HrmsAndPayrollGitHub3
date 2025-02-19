CREATE TABLE [dbo].[QR_Code_Master] (
    [QR_Code_ID]    UNIQUEIDENTIFIER NOT NULL,
    [Cmp_ID]        INT              NOT NULL,
    [Branch_ID]     INT              NULL,
    [Department_ID] INT              NULL,
    [IO_Flag]       BIT              NOT NULL,
    [POS_ID]        INT              NOT NULL,
    [Latitude]      NVARCHAR (100)   NOT NULL,
    [Longitude]     NVARCHAR (100)   NOT NULL,
    [Meters]        INT              NOT NULL,
    [Is_Active]     BIT              NOT NULL,
    CONSTRAINT [PK_QR_Code_Master] PRIMARY KEY CLUSTERED ([QR_Code_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_POS_QR_Code] FOREIGN KEY ([POS_ID]) REFERENCES [dbo].[POS_Master] ([POS_ID])
);

