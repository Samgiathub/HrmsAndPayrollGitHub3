CREATE TABLE [dbo].[Email_logs] (
    [Email_logs_id]   INT            NOT NULL,
    [cmp_id]          INT            NOT NULL,
    [Module_Name]     NVARCHAR (50)  NULL,
    [To_Email]        NVARCHAR (MAX) NULL,
    [cc_Email]        NVARCHAR (MAX) NULL,
    [sub]             NVARCHAR (50)  NULL,
    [Body_Email]      NVARCHAR (MAX) NULL,
    [Gen_Date]        DATETIME       NULL,
    [Error_Email]     NVARCHAR (MAX) NULL,
    [Attach_Path]     NVARCHAR (MAX) NULL,
    [status]          INT            CONSTRAINT [DF_Email_logs_status] DEFAULT ((0)) NOT NULL,
    [Form_Name]       VARCHAR (500)  NULL,
    [Send_Mail_Job]   TINYINT        DEFAULT ((0)) NOT NULL,
    [Email_Send_Flag] TINYINT        DEFAULT ((0)) NOT NULL,
    [Email_Send_Date] DATETIME       NULL,
    CONSTRAINT [PK_Email_logs] PRIMARY KEY CLUSTERED ([Email_logs_id] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-send,2-resend,3-fail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Email_logs', @level2type = N'COLUMN', @level2name = N'status';

