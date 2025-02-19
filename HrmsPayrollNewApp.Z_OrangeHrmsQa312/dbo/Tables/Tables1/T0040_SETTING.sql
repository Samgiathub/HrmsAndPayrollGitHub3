CREATE TABLE [dbo].[T0040_SETTING] (
    [Setting_ID]    NUMERIC (18)   NOT NULL,
    [Cmp_ID]        NUMERIC (18)   NOT NULL,
    [Setting_Name]  NVARCHAR (100) NOT NULL,
    [Setting_Value] NVARCHAR (50)  NOT NULL,
    [Comment]       VARCHAR (MAX)  NULL,
    [Group_By]      NVARCHAR (50)  CONSTRAINT [DF_T0040_SETTING_Group_By] DEFAULT (N'Others Setting') NULL,
    [Alias]         VARCHAR (300)  NULL,
    [Module_Name]   VARCHAR (100)  NULL,
    [Value_Type]    TINYINT        CONSTRAINT [DF_T0040_SETTING_Value_Type] DEFAULT ((0)) NULL,
    [Value_Ref]     VARCHAR (1024) NULL,
    CONSTRAINT [PK_T0040_SETTING] PRIMARY KEY CLUSTERED ([Setting_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_SETTING_26_480772820__K2_K3_4]
    ON [dbo].[T0040_SETTING]([Cmp_ID] ASC, [Setting_Name] ASC)
    INCLUDE([Setting_Value]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [ix_T0040_SETTING_Setting_Name]
    ON [dbo].[T0040_SETTING]([Setting_Name] ASC)
    INCLUDE([Cmp_ID], [Setting_Value]) WITH (FILLFACTOR = 90);

