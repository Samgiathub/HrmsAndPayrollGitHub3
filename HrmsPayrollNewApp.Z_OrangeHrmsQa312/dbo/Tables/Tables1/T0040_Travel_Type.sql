CREATE TABLE [dbo].[T0040_Travel_Type] (
    [Travel_Type_Id]          NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Travel_Type_Name]        VARCHAR (100) NULL,
    [Travel_Type_Description] VARCHAR (250) NULL,
    [Travel_Type_Sorting]     NUMERIC (18)  NULL,
    [DefualtState]            NUMERIC (18)  NULL,
    [Cmp_Id]                  NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_TravelType] PRIMARY KEY CLUSTERED ([Travel_Type_Id] ASC) WITH (FILLFACTOR = 95)
);

