CREATE TABLE [dbo].[temp_table] (
    [drive]  VARCHAR (15)  NOT NULL,
    [MBfree] VARCHAR (500) NULL,
    CONSTRAINT [PK_temp_table] PRIMARY KEY CLUSTERED ([drive] ASC)
);


GO
CREATE NONCLUSTERED INDEX [INDEX1]
    ON [dbo].[temp_table]([drive] ASC, [MBfree] ASC);


GO
CREATE NONCLUSTERED INDEX [INDEX2]
    ON [dbo].[temp_table]([drive] ASC)
    INCLUDE([MBfree]);

