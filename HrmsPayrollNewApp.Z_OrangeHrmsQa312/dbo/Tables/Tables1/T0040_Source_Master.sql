CREATE TABLE [dbo].[T0040_Source_Master] (
    [Source_Id]      NUMERIC (18)  NOT NULL,
    [Source_Name]    VARCHAR (100) NOT NULL,
    [Source_type_id] NUMERIC (18)  CONSTRAINT [DF_T0040_Source_Master_Source_type_id] DEFAULT ((0)) NOT NULL,
    [Comments]       VARCHAR (MAX) NULL
);

