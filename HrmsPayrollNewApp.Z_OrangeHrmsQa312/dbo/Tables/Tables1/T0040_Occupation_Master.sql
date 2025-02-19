CREATE TABLE [dbo].[T0040_Occupation_Master] (
    [O_ID]            INT            IDENTITY (1, 1) NOT NULL,
    [Occupation_Name] NVARCHAR (100) NULL,
    [Cmp_ID]          INT            NULL,
    PRIMARY KEY CLUSTERED ([O_ID] ASC) WITH (FILLFACTOR = 95)
);

