CREATE TABLE [dbo].[T0080_Dyn_Hierarchy_Comb] (
    [Dyn_Comb_Id]           NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Dyn_Cmp_Id]            NUMERIC (18) NULL,
    [Dyn_Hierarchy_Type_Id] NUMERIC (18) NULL,
    [Dyn_Cmp_Manager_Id]    NUMERIC (18) NULL,
    [Dyn_Manager_Id]        NUMERIC (18) NULL,
    [Dyn_Branch_Id]         NUMERIC (18) NULL,
    [Dyn_Dept]              NUMERIC (18) NULL,
    [Dyn_Desg]              NUMERIC (18) NULL,
    [Dyn_Grade]             NUMERIC (18) NULL,
    [Dyn_Cat]               NUMERIC (18) NULL,
    [Dyn_Band]              NUMERIC (18) NULL,
    [Dyn_Emp_type]          NUMERIC (18) NULL,
    [Dyn_Bus_Seg]           NUMERIC (18) NULL,
    [Dyn_Vertical]          NUMERIC (18) NULL,
    [Dyn_Sub_Branch_Id]     NUMERIC (18) NULL,
    [Dyn_Sub_Vertical]      NUMERIC (18) NULL,
    [Dyn_Cost_Center]       NUMERIC (18) NULL,
    [Dyn_Effective_Date]    DATETIME     NULL,
    [Dyn_System_Date]       DATETIME     NULL,
    [Dyn_User_Id]           NUMERIC (18) NULL,
    CONSTRAINT [PK_T0080_Dyn_Hier_Comb] PRIMARY KEY CLUSTERED ([Dyn_Comb_Id] ASC) WITH (FILLFACTOR = 95)
);

