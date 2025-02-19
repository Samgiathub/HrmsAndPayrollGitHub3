CREATE TABLE [dbo].[T0095_Exit_Clearance] (
    [Tran_id]        NUMERIC (18) NOT NULL,
    [Cmp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_Exit_Clearance_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Emp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_Exit_Clearance_Emp_id] DEFAULT ((0)) NOT NULL,
    [Dept_id]        NUMERIC (18) CONSTRAINT [DF_T0095_Exit_Clearance_Dept_id] DEFAULT ((0)) NULL,
    [Effective_Date] DATETIME     NULL,
    [Modify_Date]    DATETIME     CONSTRAINT [DF_T0095_Exit_Clearance_Modify_Date] DEFAULT (getdate()) NULL,
    [Center_ID]      NUMERIC (18) NULL,
    [branch_id]      NUMERIC (18) NULL,
    CONSTRAINT [PK_T0095_Exit_Clearance] PRIMARY KEY CLUSTERED ([Tran_id] ASC)
);

