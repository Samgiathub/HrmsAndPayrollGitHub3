CREATE TABLE [dbo].[T0000_DEFAULT_FORM_Backup_Graph_11112021] (
    [Form_ID]            NUMERIC (18)    NOT NULL,
    [Form_Name]          VARCHAR (100)   NOT NULL,
    [Under_Form_ID]      NUMERIC (18)    NOT NULL,
    [Sort_ID]            NUMERIC (4)     NOT NULL,
    [Form_Type]          TINYINT         NOT NULL,
    [Form_url]           VARCHAR (500)   NULL,
    [Form_Image_url]     VARCHAR (500)   NULL,
    [Is_Active_For_menu] TINYINT         NOT NULL,
    [Alias]              VARCHAR (100)   NULL,
    [Sort_Id_Check]      NUMERIC (4)     NOT NULL,
    [Module_name]        VARCHAR (100)   NULL,
    [Page_Flag]          CHAR (2)        NULL,
    [chinese_alias]      NVARCHAR (1000) NULL
);

