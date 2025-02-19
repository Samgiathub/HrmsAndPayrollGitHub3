CREATE TABLE [dbo].[T0090_EMP_PRIVILEGE_DETAILS_APP] (
    [Emp_Tran_ID]     BIGINT       NOT NULL,
    [Trans_Id]        NUMERIC (18) NOT NULL,
    [Cmp_id]          NUMERIC (18) NOT NULL,
    [Privilege_Id]    NUMERIC (18) NOT NULL,
    [From_Date]       DATETIME     NULL,
    [Approved_Emp_ID] INT          NULL,
    [Approved_Date]   DATETIME     NULL,
    [Rpt_Level]       INT          NULL,
    CONSTRAINT [FK_T0090_EMP_PRIVILEGE_DETAILS_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

