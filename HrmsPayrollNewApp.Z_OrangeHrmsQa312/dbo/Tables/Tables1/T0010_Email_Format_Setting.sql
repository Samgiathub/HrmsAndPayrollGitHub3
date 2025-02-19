CREATE TABLE [dbo].[T0010_Email_Format_Setting] (
    [Email_Type_ID]    NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Email_Type]       VARCHAR (50)  NULL,
    [Email_Title]      VARCHAR (100) NULL,
    [Email_Signature]  VARCHAR (MAX) NULL,
    [Email_Attachment] VARCHAR (MAX) NULL,
    [Notes]            VARCHAR (MAX) NULL,
    [Is_Active]        NUMERIC (18)  NULL,
    [Module_Name]      VARCHAR (100) NULL,
    [T_Id]             NUMERIC (18)  NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_T0010_Email_Format_Setting_Cmp_ID_Email_Type]
    ON [dbo].[T0010_Email_Format_Setting]([Cmp_ID] ASC, [Email_Type] ASC)
    INCLUDE([Email_Signature]) WITH (FILLFACTOR = 90);

