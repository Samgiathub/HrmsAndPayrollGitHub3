CREATE TABLE [dbo].[T0065_EMP_DOC_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT        NOT NULL,
    [Emp_Application_ID] INT           NOT NULL,
    [Row_ID]             INT           NOT NULL,
    [Cmp_ID]             INT           NOT NULL,
    [Doc_ID]             INT           NOT NULL,
    [Doc_Path]           VARCHAR (500) NOT NULL,
    [Doc_Comments]       VARCHAR (250) NOT NULL,
    [Date_of_Expiry]     DATETIME      NULL,
    [Approved_Emp_ID]    INT           NULL,
    [Approved_Date]      DATETIME      NULL,
    [Rpt_Level]          INT           NULL,
    CONSTRAINT [FK_T0065_EMP_DOC_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

