CREATE TABLE [dbo].[T0040_City_Category_Master] (
    [City_Cat_ID]   NUMERIC (18)  NOT NULL,
    [City_ID]       NUMERIC (18)  NOT NULL,
    [City_Cat_Name] VARCHAR (50)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NOT NULL,
    [Remarks]       VARCHAR (250) NULL,
    CONSTRAINT [PK_T0040_City_Category_Master] PRIMARY KEY CLUSTERED ([City_Cat_ID] ASC) WITH (FILLFACTOR = 80)
);

