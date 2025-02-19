CREATE TABLE [dbo].[T0001_IN_OUT_Flags] (
    [IOFlagId]    INT      IDENTITY (1, 1) NOT NULL,
    [IO_Tran_ID]  INT      NULL,
    [Flag]        INT      NULL,
    [CreatedDate] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IOFlagId] ASC) WITH (FILLFACTOR = 95)
);

