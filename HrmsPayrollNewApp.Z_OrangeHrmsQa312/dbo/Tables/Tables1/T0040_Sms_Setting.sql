CREATE TABLE [dbo].[T0040_Sms_Setting] (
    [Bd_Id]               NUMERIC (18)  NOT NULL,
    [Cmp_Id]              NUMERIC (18)  NOT NULL,
    [Branch_Id]           NUMERIC (18)  NULL,
    [Url]                 VARCHAR (200) NULL,
    [UserId]              VARCHAR (50)  NULL,
    [Password]            VARCHAR (50)  NULL,
    [SenderId]            VARCHAR (50)  NULL,
    [Message_Text]        VARCHAR (160) NULL,
    [Anniversary_Text]    VARCHAR (160) NULL,
    [Attendance_Text]     VARCHAR (160) NULL,
    [ForgotPassword_Text] VARCHAR (250) NULL,
    CONSTRAINT [PK_T0040_Sms_Setting] PRIMARY KEY CLUSTERED ([Bd_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Sms_Setting_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_Id]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK_T0040_Sms_Setting_T0040_Sms_Setting] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

