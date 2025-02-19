CREATE TABLE [dbo].[T0040_Exit_Analysis_rating] (
    [Rating_Id]   NUMERIC (18)   NOT NULL,
    [Cmp_Id]      NUMERIC (18)   NOT NULL,
    [Title]       NVARCHAR (250) NULL,
    [Description] NVARCHAR (250) NULL,
    [Rating]      NUMERIC (18)   CONSTRAINT [DF_T0040_Exit_Analysis_rating_Rating] DEFAULT ((0)) NOT NULL
);

