CREATE TABLE [dbo].[T0040_Change_Request_Master] (
    [Tran_id]      NUMERIC (18)  NOT NULL,
    [Request_id]   NUMERIC (18)  NULL,
    [Request_type] VARCHAR (MAX) NULL,
    [Cmp_ID]       NUMERIC (18)  NULL,
    [Flag]         BIT           NULL,
    [Max_Limit]    NUMERIC (18)  CONSTRAINT [DF_T0040_Change_Request_Master_Max_Limit] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_Change_Request_Master_MISSING_10945]
    ON [dbo].[T0040_Change_Request_Master]([Cmp_ID] ASC);

