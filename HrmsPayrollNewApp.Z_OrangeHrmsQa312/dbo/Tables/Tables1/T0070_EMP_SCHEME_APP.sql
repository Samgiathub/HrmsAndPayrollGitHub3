CREATE TABLE [dbo].[T0070_EMP_SCHEME_APP] (
    [Emp_Tran_ID]        BIGINT        NOT NULL,
    [Emp_Application_ID] INT           NOT NULL,
    [Tran_ID]            INT           NOT NULL,
    [Cmp_ID]             INT           NOT NULL,
    [Scheme_ID]          INT           NOT NULL,
    [Type]               VARCHAR (100) NOT NULL,
    [Approved_Emp_ID]    INT           NULL,
    [Approved_Date]      DATETIME      NULL,
    [Rpt_Level]          INT           NULL,
    CONSTRAINT [FK_T0070_EMP_SCHEME_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

