CREATE TABLE [dbo].[T0045_Leave_Shutdown_Period] (
    [Leave_Id]      NUMERIC (18)    NOT NULL,
    [Cmp_Id]        NUMERIC (18)    NOT NULL,
    [From_Date]     DATETIME        NOT NULL,
    [To_Date]       DATETIME        NOT NULL,
    [Notice_Period] NUMERIC (18, 2) CONSTRAINT [DF_T0045_Leave_Shutdown_Period_Notice_Period] DEFAULT ((0)) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0045_Leave_Shutdown_Period]
    ON [dbo].[T0045_Leave_Shutdown_Period]([Leave_Id] ASC, [From_Date] ASC);

