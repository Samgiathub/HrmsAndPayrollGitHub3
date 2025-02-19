CREATE TABLE [dbo].[T0010_Email_Format_Setting_History] (
    [Email_Type_ID]    NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Email_Type]       VARCHAR (50)  NULL,
    [Email_Title]      VARCHAR (100) NULL,
    [Email_Signature]  VARCHAR (MAX) NULL,
    [Email_Attachment] VARCHAR (MAX) NULL,
    [Notes]            VARCHAR (MAX) NULL,
    [Login_ID]         NUMERIC (18)  NULL,
    [Sys_Date]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Email_Type_ID] ASC)
);

