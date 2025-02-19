CREATE TABLE [dbo].[T0050_Template_Field_Master] (
    [F_ID]        INT            NOT NULL,
    [Cmp_ID]      INT            NOT NULL,
    [T_ID]        INT            NOT NULL,
    [Field_Name]  NVARCHAR (100) NULL,
    [Field_Type]  NVARCHAR (100) NULL,
    [Options]     NVARCHAR (MAX) NULL,
    [Sorting_No]  INT            NULL,
    [Is_Required] INT            NULL,
    [Is_Enable]   INT            NULL,
    [Is_Numeric]  INT            NULL,
    CONSTRAINT [PK_T0050_Template_Field_Master] PRIMARY KEY CLUSTERED ([F_ID] ASC) WITH (FILLFACTOR = 80)
);

