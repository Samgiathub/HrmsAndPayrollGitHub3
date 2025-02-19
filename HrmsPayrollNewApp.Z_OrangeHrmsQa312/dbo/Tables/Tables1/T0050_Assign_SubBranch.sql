CREATE TABLE [dbo].[T0050_Assign_SubBranch] (
    [Tran_ID]        INT            NOT NULL,
    [Cmp_ID]         INT            NULL,
    [Emp_ID]         NUMERIC (18)   NULL,
    [Effective_Date] DATETIME       NULL,
    [SubBranch_ID]   NVARCHAR (500) NULL,
    [User_ID]        INT            NULL,
    CONSTRAINT [PK_T0050_Assign_SubBranch] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

