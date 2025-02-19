CREATE TABLE [dbo].[T0050_LEAVE_CF_SLAB] (
    [Slab_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [Effective_Date] DATETIME        NULL,
    [Type_ID]        NUMERIC (18)    NULL,
    [Leave_ID]       NUMERIC (18)    NULL,
    [From_Days]      NUMERIC (18, 2) NULL,
    [To_Days]        NUMERIC (18, 2) NULL,
    [CF_Days]        NUMERIC (18, 2) NULL,
    [SLAB_FLAG]      CHAR (2)        NULL,
    CONSTRAINT [PK_T0050_LEAVE_CF_SLAB] PRIMARY KEY CLUSTERED ([Slab_ID] ASC) WITH (FILLFACTOR = 80)
);

