CREATE TABLE [dbo].[T0040_Milestone_Master] (
    [Milestone_ID]          NUMERIC (18)  NOT NULL,
    [Milestone_Name]        VARCHAR (50)  NULL,
    [Milestone_Description] VARCHAR (100) NULL,
    [Cmp_ID]                NUMERIC (18)  NULL,
    [Created_By]            NUMERIC (18)  NULL,
    [Created_Date]          DATETIME      NULL,
    [Modify_By]             NUMERIC (18)  NULL,
    [Modify_Date]           DATETIME      NULL,
    CONSTRAINT [PK_T0040_Milestone_Master] PRIMARY KEY CLUSTERED ([Milestone_ID] ASC) WITH (FILLFACTOR = 80)
);

