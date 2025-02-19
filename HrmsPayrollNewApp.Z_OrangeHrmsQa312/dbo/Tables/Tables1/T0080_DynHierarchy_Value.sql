CREATE TABLE [dbo].[T0080_DynHierarchy_Value] (
    [DynHierarchyId]  NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_ID]          NUMERIC (18)  NULL,
    [Cmp_ID]          NUMERIC (18)  NULL,
    [DynHierColName]  VARCHAR (200) NULL,
    [DynHierColValue] NUMERIC (18)  NULL,
    [DynHierColId]    NUMERIC (18)  NULL,
    [IncrementId]     NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0080_DynHierarchy_Value] PRIMARY KEY CLUSTERED ([DynHierarchyId] ASC) WITH (FILLFACTOR = 95)
);

