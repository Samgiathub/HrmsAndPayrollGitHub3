CREATE TABLE [dbo].[T0095_Department_Manager] (
    [tran_id]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_Department_Manager_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Emp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_Department_Manager_Emp_id] DEFAULT ((0)) NOT NULL,
    [Dept_Id]        NUMERIC (18) CONSTRAINT [DF_T0095_Department_Manager_Dept_Id] DEFAULT ((0)) NOT NULL,
    [Effective_Date] DATETIME     NULL,
    [modify_Date]    DATETIME     CONSTRAINT [DF_T0095_Department_Manager_modify_Date] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_T0095_Department_Manager] PRIMARY KEY CLUSTERED ([tran_id] ASC) WITH (FILLFACTOR = 80)
);

