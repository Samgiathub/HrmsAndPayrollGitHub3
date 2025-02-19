CREATE TABLE [dbo].[T0030_Hrms_Training_Category] (
    [Training_Category_ID]   NUMERIC (18)  NOT NULL,
    [Cmp_Id]                 NUMERIC (18)  NOT NULL,
    [Training_Category_Name] VARCHAR (250) NOT NULL,
    [Parent_categoryId]      NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0030_Hrms_Training_Category] PRIMARY KEY CLUSTERED ([Training_Category_ID] ASC) WITH (FILLFACTOR = 80)
);

