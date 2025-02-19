CREATE TABLE [dbo].[Mittsure_Json_Master] (
    [Pk_PID]          VARCHAR (200) NOT NULL,
    [Fk_Staff_ID]     VARCHAR (200) NOT NULL,
    [Staff_Name]      VARCHAR (250) NULL,
    [Start_date_time] VARCHAR (200) NULL,
    [End_date_time]   VARCHAR (200) NULL,
    [Start_Lat]       VARCHAR (200) NULL,
    [Start_Log]       VARCHAR (200) NULL,
    [End_Lat]         VARCHAR (200) NULL,
    [End_Log]         VARCHAR (200) NULL,
    [Emp_ID]          VARCHAR (200) NOT NULL,
    [Is_Sync]         BIT           NULL,
    CONSTRAINT [PK_Mittsure_Json_Master] PRIMARY KEY CLUSTERED ([Pk_PID] ASC) WITH (FILLFACTOR = 95)
);

