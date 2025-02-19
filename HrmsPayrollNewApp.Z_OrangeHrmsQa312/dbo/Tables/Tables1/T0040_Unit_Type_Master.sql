CREATE TABLE [dbo].[T0040_Unit_Type_Master] (
    [Unit_Type_Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]         INT           NULL,
    [Unit_Type_Name] VARCHAR (50)  NULL,
    [System_Date]    SMALLDATETIME NULL,
    CONSTRAINT [PK_T0040_Unit_Type_Master] PRIMARY KEY CLUSTERED ([Unit_Type_Id] ASC)
);

