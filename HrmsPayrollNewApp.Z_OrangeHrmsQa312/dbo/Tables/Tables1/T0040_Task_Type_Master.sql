CREATE TABLE [dbo].[T0040_Task_Type_Master] (
    [Task_Type_ID]         NUMERIC (18)  NOT NULL,
    [TaskType_Name]        VARCHAR (50)  NULL,
    [TaskType_Description] VARCHAR (MAX) NULL,
    [Cmp_ID]               NUMERIC (18)  NULL,
    [Created_By]           NUMERIC (18)  NULL,
    [Created_Date]         DATETIME      NULL,
    [Modify_By]            NUMERIC (18)  NULL,
    [Modify_Date]          DATETIME      NULL,
    CONSTRAINT [PK_T0040_Task_Type_Master] PRIMARY KEY CLUSTERED ([Task_Type_ID] ASC) WITH (FILLFACTOR = 80)
);

