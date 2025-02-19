CREATE TABLE [dbo].[T0080_Template_FieldBank] (
    [TFB_ID]     INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]     INT            NOT NULL,
    [Field_Name] NVARCHAR (100) NULL,
    [Field_Type] NVARCHAR (100) NULL,
    [Options]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0080_Template_FieldBank] PRIMARY KEY CLUSTERED ([TFB_ID] ASC) WITH (FILLFACTOR = 95)
);

