CREATE TABLE [dbo].[t0299_Schedule_Master] (
    [Sch_id]        NUMERIC (18)   CONSTRAINT [DF_t0299_Schedule_Master_Sch_id] DEFAULT ((0)) NOT NULL,
    [Sch_Name]      VARCHAR (200)  NOT NULL,
    [Reminder_Name] VARCHAR (500)  NOT NULL,
    [Sch_Type]      VARCHAR (200)  NOT NULL,
    [Date_run]      NUMERIC (18)   CONSTRAINT [DF_t0299_Schedule_Master_Date_run] DEFAULT ((0)) NOT NULL,
    [Date_Weekly]   VARCHAR (500)  NULL,
    [Sch_time]      VARCHAR (100)  NULL,
    [Cc_Email_Id]   VARCHAR (MAX)  NULL,
    [modify_date]   DATETIME       CONSTRAINT [DF_t0299_Schedule_Master_modify_date] DEFAULT (getdate()) NULL,
    [cmp_id]        NUMERIC (18)   CONSTRAINT [DF_t0299_Schedule_Master_cmp_id] DEFAULT ((0)) NOT NULL,
    [Sch_Hours]     NUMERIC (18)   CONSTRAINT [DF_t0299_Schedule_Master_Sch_Hours] DEFAULT ((0)) NULL,
    [is_time]       TINYINT        NULL,
    [Parameter]     VARCHAR (MAX)  NULL,
    [LeaveIDs]      VARCHAR (1024) DEFAULT ('') NULL,
    CONSTRAINT [PK_t0299_Schedule_Master] PRIMARY KEY CLUSTERED ([Sch_id] ASC) WITH (FILLFACTOR = 80)
);

