CREATE TABLE [dbo].[T0010_Email_Format_Setting_Default] (
    [Email_Type_ID]    NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Email_Type]       VARCHAR (50)  NULL,
    [Email_Title]      VARCHAR (100) NULL,
    [Email_Signature]  VARCHAR (MAX) NULL,
    [Email_Attachment] VARCHAR (MAX) NULL,
    [Notes]            VARCHAR (MAX) NULL,
    [Is_Active]        NUMERIC (18)  NULL,
    [Module_Name]      VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([Email_Type_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_T0010_Email_Format_Setting_Default_MISSING_10969]
    ON [dbo].[T0010_Email_Format_Setting_Default]([Cmp_ID] ASC, [Email_Type] ASC);

