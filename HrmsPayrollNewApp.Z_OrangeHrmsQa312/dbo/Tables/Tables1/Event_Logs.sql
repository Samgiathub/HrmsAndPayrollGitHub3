CREATE TABLE [dbo].[Event_Logs] (
    [Log_Id]      NUMERIC (18)   NOT NULL,
    [Cmp_Id]      NUMERIC (18)   NOT NULL,
    [Emp_Id]      NUMERIC (18)   NULL,
    [Login_Id]    NUMERIC (18)   NULL,
    [Module_Name] NVARCHAR (100) NULL,
    [Error_Name]  NVARCHAR (100) NULL,
    [Description] NVARCHAR (MAX) NULL,
    [System_Date] DATETIME       NOT NULL,
    [Event_Flag]  TINYINT        NOT NULL,
    [Remarks]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Event_Logs] PRIMARY KEY CLUSTERED ([Log_Id] ASC) WITH (FILLFACTOR = 80)
);

