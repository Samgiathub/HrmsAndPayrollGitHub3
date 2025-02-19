CREATE TABLE [dbo].[T0200_Salary_Budget] (
    [SalBudget_ID]       NUMERIC (18)  NOT NULL,
    [SalBudget_Type]     VARCHAR (50)  NULL,
    [SalBudget_Date]     DATETIME      NULL,
    [Cmp_ID]             NUMERIC (18)  NULL,
    [Created_By]         NUMERIC (18)  NULL,
    [Created_Date]       DATETIME      NULL,
    [Modified_By]        NUMERIC (18)  NULL,
    [Modified_Date]      DATETIME      NULL,
    [Branch_Ids]         VARCHAR (MAX) NULL,
    [SubBranch_Ids]      VARCHAR (MAX) NULL,
    [Grade_Ids]          VARCHAR (MAX) NULL,
    [Type_Ids]           VARCHAR (MAX) NULL,
    [Dept_Ids]           VARCHAR (MAX) NULL,
    [Desig_Ids]          VARCHAR (MAX) NULL,
    [Cat_Ids]            VARCHAR (MAX) NULL,
    [BusSegment_Ids]     VARCHAR (MAX) NULL,
    [Vertical_Ids]       VARCHAR (MAX) NULL,
    [SubVertical_Ids]    VARCHAR (MAX) NULL,
    [Appraisal_DateFrom] DATETIME      NULL,
    [Appraisal_DateTo]   DATETIME      NULL,
    CONSTRAINT [PK_T0200_Salary_Budget] PRIMARY KEY CLUSTERED ([SalBudget_ID] ASC)
);

