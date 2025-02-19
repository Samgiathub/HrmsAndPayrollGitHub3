CREATE TABLE [dbo].[T0040_Setting_Display_Fields] (
    [Tran_ID]              INT           NOT NULL,
    [Cmp_ID]               NUMERIC (18)  NULL,
    [Module_Name]          VARCHAR (100) NULL,
    [Field_Name]           VARCHAR (150) NULL,
    [Control_Type]         VARCHAR (50)  NULL,
    [Control_Display_Name] VARCHAR (250) NULL,
    [Is_Display]           BIT           NULL,
    [Sorting_No]           INT           NULL,
    [Modify_By]            INT           NULL,
    [Modify_Date]          DATETIME      NULL,
    [IP_Address]           VARCHAR (50)  NULL,
    CONSTRAINT [PK_T0040_Setting_Display_Fields] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0040_Setting_Display_Fields_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

