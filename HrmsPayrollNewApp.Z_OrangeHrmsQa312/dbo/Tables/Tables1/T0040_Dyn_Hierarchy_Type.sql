CREATE TABLE [dbo].[T0040_Dyn_Hierarchy_Type] (
    [Dyn_Hierarchy_Id]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Dyn_Hierarchy_Type]       VARCHAR (50)  NULL,
    [Dyn_Hierarchy_Sorting_No] NUMERIC (18)  NULL,
    [Dyn_Hierarchy_Descrip]    VARCHAR (150) NULL,
    [Cmp_id]                   NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_Dyn_Hierarchy_Type] PRIMARY KEY CLUSTERED ([Dyn_Hierarchy_Id] ASC) WITH (FILLFACTOR = 95)
);

