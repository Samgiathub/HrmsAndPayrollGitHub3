CREATE TABLE [dbo].[t9999_Reminder_Mail_Profile] (
    [DB_Mail_Profile_Id]   INT             NOT NULL,
    [DB_Mail_Profile_Name] VARCHAR (50)    CONSTRAINT [DF_t9999_Reminder_Mail_Profile_DB_Mail_Profile_Name] DEFAULT ('') NOT NULL,
    [cmp_id]               INT             NOT NULL,
    [Email_Id]             VARCHAR (500)   NULL,
    [Password]             VARBINARY (MAX) NULL,
    [Remark]               VARCHAR (50)    NULL,
    [Server_link]          VARCHAR (500)   NULL,
    [DB_Backup_Path]       VARCHAR (1000)  NULL,
    CONSTRAINT [PK_t9999_Reminder_Mail_Profile] PRIMARY KEY CLUSTERED ([DB_Mail_Profile_Id] ASC) WITH (FILLFACTOR = 80)
);

