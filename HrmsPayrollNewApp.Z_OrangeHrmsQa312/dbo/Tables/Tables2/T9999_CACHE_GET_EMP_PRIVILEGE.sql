CREATE TABLE [dbo].[T9999_CACHE_GET_EMP_PRIVILEGE] (
    [Trans_Id]      NUMERIC (19)  NULL,
    [Privilage_ID]  NUMERIC (18)  NOT NULL,
    [cmp_id]        NUMERIC (18)  NOT NULL,
    [Form_ID]       NUMERIC (18)  NOT NULL,
    [Is_View]       INT           NULL,
    [is_edit]       INT           NULL,
    [is_save]       INT           NULL,
    [is_delete]     INT           NULL,
    [is_print]      INT           NULL,
    [Form_Name]     VARCHAR (100) NOT NULL,
    [Under_Form_ID] NUMERIC (18)  NOT NULL,
    [Module_name]   VARCHAR (100) NULL,
    [Page_Flag]     CHAR (2)      NULL,
    [Privilege_ID]  INT           NULL,
    [ExpiryDate]    DATETIME      NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [CLIX_T9999_CACHE_GET_EMP_PRIVILEGE]
    ON [dbo].[T9999_CACHE_GET_EMP_PRIVILEGE]([Privilege_ID] ASC, [Form_ID] ASC, [Trans_Id] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [NCIX_T9999_CACHE_GET_EMP_PRIVILEGE]
    ON [dbo].[T9999_CACHE_GET_EMP_PRIVILEGE]([Privilege_ID] ASC, [ExpiryDate] DESC) WITH (FILLFACTOR = 95);

