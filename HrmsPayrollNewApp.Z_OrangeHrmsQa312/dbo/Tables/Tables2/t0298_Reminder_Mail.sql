CREATE TABLE [dbo].[t0298_Reminder_Mail] (
    [Reminder_Id]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Reminder_Name] VARCHAR (500) NOT NULL,
    [Reminder_Sp]   VARCHAR (100) NULL,
    [Discription]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_t0298_Reminder_Mail] PRIMARY KEY CLUSTERED ([Reminder_Id] ASC) WITH (FILLFACTOR = 80)
);

