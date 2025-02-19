CREATE TABLE [dbo].[T0110_Task_Audit] (
    [Task_Audit_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [Task_Id]          INT           NULL,
    [Task_Detail_Id]   INT           NULL,
    [Task_Field]       VARCHAR (100) NULL,
    [Task_OldValue]    VARCHAR (MAX) NULL,
    [Task_NewValue]    VARCHAR (MAX) NULL,
    [Updated_Emp_Id]   INT           NULL,
    [Task_UpdatedDate] SMALLDATETIME CONSTRAINT [DF_T0110_Task_Audit_Task_UpdatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_T0110_Task_Audit] PRIMARY KEY CLUSTERED ([Task_Audit_Id] ASC)
);

