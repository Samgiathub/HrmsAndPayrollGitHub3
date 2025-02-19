CREATE TABLE [dbo].[T9999_Auto_Escalate_Setting] (
    [Tran_id]             NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]              NUMERIC (18) CONSTRAINT [DF_T9999_Auto_Escalate_Setting_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Is_Enable]           TINYINT      CONSTRAINT [DF_Table_1_Is_enable] DEFAULT ((0)) NOT NULL,
    [Escalate_After_days] NUMERIC (18) CONSTRAINT [DF_T9999_Auto_Escalate_Setting_Escalate_After_days] DEFAULT ((0)) NOT NULL,
    [Auto_Approve]        NUMERIC (18) CONSTRAINT [DF_T9999_Auto_Escalate_Setting_Auto_Approve] DEFAULT ((0)) NOT NULL,
    [is_sql_job_agent]    TINYINT      CONSTRAINT [DF_T9999_Auto_Escalate_Setting_is_sql_job_agent] DEFAULT ((0)) NOT NULL,
    [is_Auto_reject]      TINYINT      CONSTRAINT [DF_T9999_Auto_Escalate_Setting_is_Auto_reject] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T9999_Auto_Escalate_Setting] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

