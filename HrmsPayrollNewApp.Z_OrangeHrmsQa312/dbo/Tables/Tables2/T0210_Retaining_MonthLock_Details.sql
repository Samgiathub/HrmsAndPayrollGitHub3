CREATE TABLE [dbo].[T0210_Retaining_MonthLock_Details] (
    [tran_id]                NUMERIC (18)    NOT NULL,
    [cmp_id]                 NUMERIC (18)    NOT NULL,
    [Retain_Start_date]      DATETIME        NULL,
    [Retain_End_date]        DATETIME        NULL,
    [Days]                   NUMERIC (18, 2) NULL,
    [Slab_Id]                NUMERIC (18, 2) NULL,
    [Slab_Per]               NUMERIC (18, 2) NULL,
    [Mode]                   VARCHAR (50)    NULL,
    [Retain_Slab_start_Date] DATETIME        NULL,
    [Retain_Slab_end_Date]   DATETIME        NULL,
    [Mnlock_StDate]          DATETIME        NULL,
    [Mnlock_EndDate]         DATETIME        NULL,
    [Mnlock_Id]              INT             NULL
);

