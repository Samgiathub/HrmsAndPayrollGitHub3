CREATE TABLE [dbo].[T0010_Email_Setting] (
    [tran_Id]                NUMERIC (18)    NOT NULL,
    [cmp_id]                 NUMERIC (18)    NOT NULL,
    [MailServer]             NVARCHAR (500)  NOT NULL,
    [MailServer_Port]        NUMERIC (18)    NOT NULL,
    [MailServer_UserName]    NVARCHAR (1000) NOT NULL,
    [MailServer_Password]    NVARCHAR (500)  NOT NULL,
    [Ssl]                    TINYINT         NOT NULL,
    [MailServer_DisplayName] NVARCHAR (500)  NOT NULL,
    [From_Email]             NVARCHAR (500)  NOT NULL,
    [isMES]                  TINYINT         CONSTRAINT [DF_T0010_Email_Setting_isMES] DEFAULT ((0)) NULL,
    [MESURI]                 NVARCHAR (500)  CONSTRAINT [DF_T0010_Email_Setting_MESURI] DEFAULT ('') NULL,
    [MESReplyTo]             NVARCHAR (500)  NULL,
    [system_date]            DATETIME        CONSTRAINT [DF_T0010_Email_Setting_system_date] DEFAULT (getdate()) NOT NULL,
    [user_id]                NUMERIC (18)    NOT NULL,
    [To_Email]               NVARCHAR (500)  CONSTRAINT [DF_T0010_Email_Setting_To_Email] DEFAULT ('') NOT NULL
);

