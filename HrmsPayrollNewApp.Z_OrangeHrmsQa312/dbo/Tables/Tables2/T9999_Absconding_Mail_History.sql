CREATE TABLE [dbo].[T9999_Absconding_Mail_History] (
    [Abs_Tran_ID]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_ID]              NUMERIC (18)  NOT NULL,
    [Cmp_ID]              NUMERIC (18)  NOT NULL,
    [Reminder_One_Date]   DATETIME      NOT NULL,
    [Reminder_One_Sent]   TINYINT       CONSTRAINT [DF_T9999_Absconding_Mail_History_Reminder_One_Sent] DEFAULT ((0)) NOT NULL,
    [Reason_One]          VARCHAR (500) NULL,
    [Reminder_Two_Date]   DATETIME      NULL,
    [Reminder_Two_Sent]   TINYINT       CONSTRAINT [DF_T9999_Absconding_Mail_History_Reminder_Two_Sent] DEFAULT ((0)) NOT NULL,
    [Reason_Two]          VARCHAR (500) NULL,
    [Reminder_Three_Date] DATETIME      NULL,
    [Reminder_Three_Sent] TINYINT       CONSTRAINT [DF_T9999_Absconding_Mail_History_Reminder_Three_Sent] DEFAULT ((0)) NOT NULL,
    [Reason_Three]        VARCHAR (500) NULL,
    CONSTRAINT [PK_T9999_Absconding_Mail_History] PRIMARY KEY NONCLUSTERED ([Abs_Tran_ID] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T9999_Absconding_Mail_History_EMP_ID_CMP_ID]
    ON [dbo].[T9999_Absconding_Mail_History]([Emp_ID] ASC, [Reminder_One_Date] DESC);

