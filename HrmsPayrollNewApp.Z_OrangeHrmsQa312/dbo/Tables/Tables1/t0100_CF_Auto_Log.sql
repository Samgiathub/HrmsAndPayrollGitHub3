CREATE TABLE [dbo].[t0100_CF_Auto_Log] (
    [RowId]          NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Leave_Id]       NUMERIC (18)  NULL,
    [SystemDateTime] DATETIME      NULL,
    [Is_Success]     TINYINT       NULL,
    [From_Date]      DATETIME      NULL,
    [To_Date]        DATETIME      NULL,
    [Comment]        VARCHAR (400) NULL,
    CONSTRAINT [PK_t0100_CF_Auto_Log] PRIMARY KEY CLUSTERED ([RowId] ASC) WITH (FILLFACTOR = 80)
);

