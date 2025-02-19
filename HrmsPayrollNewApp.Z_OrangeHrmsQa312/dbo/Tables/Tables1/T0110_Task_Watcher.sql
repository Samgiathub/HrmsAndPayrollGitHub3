CREATE TABLE [dbo].[T0110_Task_Watcher] (
    [Task_Watcher_Id] INT IDENTITY (1, 1) NOT NULL,
    [Task_Id]         INT NULL,
    [Emp_Id]          INT NULL,
    CONSTRAINT [PK_T0110_Task_Watcher] PRIMARY KEY CLUSTERED ([Task_Watcher_Id] ASC)
);

