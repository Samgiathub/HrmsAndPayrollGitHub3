CREATE TABLE [dbo].[T0065_EMP_QUALIFICATION_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT         NOT NULL,
    [Emp_Application_ID] INT            NOT NULL,
    [Row_ID]             INT            NOT NULL,
    [Cmp_ID]             INT            NOT NULL,
    [Qual_ID]            INT            NOT NULL,
    [Specialization]     VARCHAR (100)  NULL,
    [Year]               NUMERIC (18)   NULL,
    [Score]              VARCHAR (20)   NULL,
    [St_Date]            DATETIME       NULL,
    [End_Date]           DATETIME       NULL,
    [Comments]           VARCHAR (250)  NULL,
    [attach_doc]         NVARCHAR (MAX) NULL,
    [Approved_Emp_ID]    INT            NULL,
    [Approved_Date]      DATETIME       NULL,
    [Rpt_Level]          INT            NULL,
    CONSTRAINT [FK_T0065_EMP_QUALIFICATION_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

