CREATE TABLE [dbo].[T0065_EMP_CONTRACT_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT        NOT NULL,
    [Emp_Application_ID] INT           NOT NULL,
    [Tran_ID]            INT           NOT NULL,
    [Cmp_ID]             INT           NOT NULL,
    [Prj_ID]             INT           NOT NULL,
    [Start_Date]         DATETIME      NOT NULL,
    [End_Date]           DATETIME      NOT NULL,
    [Is_Renew]           TINYINT       NOT NULL,
    [Is_Reminder]        TINYINT       NOT NULL,
    [Comments]           VARCHAR (200) NULL,
    [Approved_Emp_ID]    INT           NULL,
    [Approved_Date]      DATETIME      NULL,
    [Rpt_Level]          INT           NULL,
    CONSTRAINT [FK_T0065_EMP_CONTRACT_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

