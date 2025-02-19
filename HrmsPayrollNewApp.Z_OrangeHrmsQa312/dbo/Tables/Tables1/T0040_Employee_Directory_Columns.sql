CREATE TABLE [dbo].[T0040_Employee_Directory_Columns] (
    [Field_ID]    INT          IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]      NUMERIC (18) NOT NULL,
    [Field_Name]  VARCHAR (50) NOT NULL,
    [Field_Label] VARCHAR (50) NOT NULL,
    [Data_Type]   VARCHAR (50) NOT NULL,
    [Is_Show]     BIT          NOT NULL,
    [Sort_Index]  INT          NOT NULL,
    [DBField]     AS           (case when [Data_Type]='VARCHAR' then ('ISNULL('+[Field_Name])+','''')' when [Data_Type]='DATETIME' then ('ISNULL('+[Field_Name])+','''')' else [Field_Name] end),
    CONSTRAINT [PK_T0040_Employee_Directory_Columns] PRIMARY KEY CLUSTERED ([Field_ID] ASC)
);

