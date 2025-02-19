CREATE TABLE [dbo].[T0070_WEEKOFF_ADJ_APP] (
    [Emp_Tran_ID]         BIGINT        NOT NULL,
    [Emp_Application_ID]  INT           NOT NULL,
    [W_Tran_ID]           INT           NOT NULL,
    [Cmp_ID]              INT           NOT NULL,
    [Weekoff_Day]         VARCHAR (100) NOT NULL,
    [Weekoff_Day_Value]   VARCHAR (100) NULL,
    [Alt_W_Name]          VARCHAR (100) NULL,
    [Alt_W_Full_Day_Cont] VARCHAR (50)  NULL,
    [Alt_W_Half_Day_Cont] VARCHAR (50)  NULL,
    [Is_P_Comp]           TINYINT       NULL,
    [Approved_Emp_ID]     INT           NULL,
    [Approved_Date]       DATETIME      NULL,
    [Rpt_Level]           INT           NULL,
    CONSTRAINT [FK_T0070_WEEKOFF_ADJ_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

