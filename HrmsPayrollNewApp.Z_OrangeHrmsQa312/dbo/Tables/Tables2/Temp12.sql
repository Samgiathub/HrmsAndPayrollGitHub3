CREATE TABLE [dbo].[Temp12] (
    [Tran_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Emp_ID]          NUMERIC (18)  NOT NULL,
    [Scheme_Id]       NUMERIC (18)  NOT NULL,
    [Type]            VARCHAR (100) NOT NULL,
    [Effective_Date]  DATETIME      NOT NULL,
    [IsMakerChecker]  BIT           NULL,
    [RptLevel]        NUMERIC (18)  NULL,
    [DynHierId]       NUMERIC (18)  NULL,
    [TravelTypeId]    VARCHAR (50)  NULL,
    [DynHierarchyId]  NUMERIC (18)  NOT NULL,
    [DynHierColName]  VARCHAR (200) NULL,
    [DynHierColValue] NUMERIC (18)  NULL,
    [DynHierColId]    NUMERIC (18)  NULL,
    [IncrementId]     NUMERIC (18)  NULL,
    [AppId]           NUMERIC (18)  NULL
);

