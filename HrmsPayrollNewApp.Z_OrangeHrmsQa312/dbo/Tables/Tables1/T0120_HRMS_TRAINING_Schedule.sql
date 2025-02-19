CREATE TABLE [dbo].[T0120_HRMS_TRAINING_Schedule] (
    [Schedule_ID]     NUMERIC (18)  NOT NULL,
    [Training_App_ID] NUMERIC (18)  NULL,
    [From_date]       DATETIME      NULL,
    [To_date]         DATETIME      NULL,
    [From_Time]       NVARCHAR (20) NULL,
    [To_Time]         NVARCHAR (20) NULL,
    [Cmp_Id]          NUMERIC (18)  NULL
);

